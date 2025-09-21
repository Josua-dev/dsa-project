import ballerina/grpc;
import ballerina/time;
import stubs.carrental;


map<carrental:Car> carDatabase = {};
map<carrental:Customer> customerDatabase = {};
map<string, carrental:CartItem[]> carts = {};
map<string, carrental:Reservation> reservations = {};

service /carrental on new grpc:Listener(9090) {

    remote function addCar(carrental:AddCarRequest req) returns carrental:AddCarResponse {
        carDatabase[req.car.numberPlate] = req.car;
        return { numberPlate: req.car.numberPlate };
    }

    remote function updateCar(carrental:UpdateCarRequest req) returns carrental:Empty {
        if carDatabase.hasKey(req.car.numberPlate) {
            carDatabase[req.car.numberPlate] = req.car;
        }
        return {};
    }

    remote function removeCar(carrental:RemoveCarRequest req) returns carrental:RemoveCarResponse {
        carDatabase.remove(req.numberPlate);
        return { cars: carDatabase.values().toArray() };
    }

    remote function listAvailableCars(carrental:ListAvailableCarsRequest req) returns stream<carrental:Car, grpc:Error?> {
        stream<carrental:Car, grpc:Error?> carStream = new;
        foreach var car in carDatabase.values() {
            if car.status == carrental:CarStatus.AVAILABLE &&
               (req.filter == "" || car.make.contains(req.filter) || car.model.contains(req.filter)) {
                carStream.send(car);
            }
        }
        carStream.complete();
        return carStream;
    }

    remote function searchCar(carrental:SearchCarRequest req) returns carrental:SearchCarResponse {
        carrental:Car? car = carDatabase[req.numberPlate];
        if car is carrental:Car {
            return { car: car, available: car.status == carrental:CarStatus.AVAILABLE };
        }
        return { car: {}, available: false };
    }

    remote function addToCart(carrental:AddToCartRequest req) returns carrental:Empty {
        carrental:CartItem[] cart = carts.get(req.customerId) ?? [];
        cart.push(req.item);
        carts[req.customerId] = cart;
        return {};
    }

    remote function placeReservation(carrental:PlaceReservationRequest req) returns carrental:PlaceReservationResponse {
        carrental:CartItem[] cart = carts.get(req.customerId) ?? [];
        double total = 0;
        foreach var item in cart {
            carrental:Car? car = carDatabase[item.numberPlate];
            if car is carrental:Car && car.status == carrental:CarStatus.AVAILABLE {
                time:Utc start = check time:parse(item.startDate);
                time:Utc end = check time:parse(item.endDate);
                int days = time:daysBetween(start, end);
                total += days * car.dailyPrice;
            }
        }
        carts.remove(req.customerId);
        string resId = "R" + time:currentTime().epochSecond().toString();
        carrental:Reservation res = { reservationId: resId, customerId: req.customerId, rentedCars: cart, totalPrice: total };
        reservations[resId] = res;
        return { reservation: res };
    }

    remote function createCustomer(carrental:CreateCustomerRequest req) returns carrental:CreateCustomerResponse {
        foreach var c in req.customers {
            customerDatabase[c.customerId] = c;
        }
        return { message: "Customers created successfully" };
    }
}
