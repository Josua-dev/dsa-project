import ballerina/grpc;
import ballerina/uuid;
import ballerina/log;
import ballerina/io;

// Data storage
map<Car> carInventory = {};
map<User> users = {};
map<CartItem[]> customerCarts = {};

type CartItem record {
    string plate;
    string startDate;
    string endDate;
};

listener grpc:Listener ep = new (9090);

service "CarRentalService" on ep {
    
    remote function AddCar(Car car) returns CarResponse {
        carInventory[car.plate] = car;
        io:println("Car added: ", car);
        return {
            success: true,
            message: "Car added successfully",
            car: car
        };
    }
    
    remote function UpdateCar(Car car) returns CarResponse {
        if carInventory.hasKey(car.plate) {
            carInventory[car.plate] = car;
            io:println("Car updated: ", car);
            return {
                success: true,
                message: "Car updated successfully",
                car: car
            };
        }
        return {
            success: false,
            message: "Car not found",
            car: {}
        };
    }
    
    remote function RemoveCar(CarRequest request) returns CarListResponse {
        _ = carInventory.remove(request.plate);
        io:println("Car removed: ", request.plate);
        return {cars: carInventory.toArray()};
    }
    
    remote function SearchCar(CarRequest request) returns CarResponse {
        if carInventory.hasKey(request.plate) {
            Car car = carInventory.get(request.plate);
            io:println("Car found: ", car);
            if car.status == "AVAILABLE" {
                return {
                    success: true,
                    message: "Car found and available",
                    car: car
                };
            }
            return {
                success: false,
                message: "Car found but not available",
                car: car
            };
        }
        return {
            success: false,
            message: "Car not found",
            car: {}
        };
    }
    
    remote function AddToCart(CartRequest request) returns CartResponse {
        if !carInventory.hasKey(request.plate) {
            return {success: false, message: "Car not found"};
        }
        
        if !customerCarts.hasKey(request.customer_id) {
            customerCarts[request.customer_id] = [];
        }
        
        CartItem newItem = {
            plate: request.plate,
            startDate: request.start_date,
            endDate: request.end_date
        };
        
        CartItem[]? cart = customerCarts[request.customer_id];
        if cart is CartItem[] {
            cart.push(newItem);
        }
        
        io:println("Added to cart: ", newItem);
        return {success: true, message: "Car added to cart"};
    }
    
    remote function PlaceReservation(ReservationRequest request) returns ReservationResponse {
        if !customerCarts.hasKey(request.customer_id) {
            return {
                success: false,
                message: "Cart is empty",
                total_price: 0.0,
                reservation_id: ""
            };
        }
        
        CartItem[]? cart = customerCarts[request.customer_id];
        if cart is () || cart.length() == 0 {
            return {
                success: false,
                message: "Cart is empty",
                total_price: 0.0,
                reservation_id: ""
            };
        }
        
        float totalPrice = 0.0;
        string reservationId = uuid:createType1AsString();
        
        foreach CartItem item in cart {
            if carInventory.hasKey(item.plate) {
                Car car = carInventory.get(item.plate);
                int days = 7;
                totalPrice += car.daily_price * days;
            }
        }
        
        customerCarts[request.customer_id] = [];
        
        io:println("Reservation placed: ", reservationId, " Total: ", totalPrice);
        return {
            success: true,
            message: "Reservation placed successfully",
            total_price: totalPrice,
            reservation_id: reservationId
        };
    }
    
    remote function CreateUsers(stream<User, grpc:Error?> clientStream) returns UserResponse {
        error? e = clientStream.forEach(function(User user) {
            users[user.user_id] = user;
            io:println("User created: ", user);
        });
        
        if e is error {
            return {success: false, message: "Error creating users"};
        }
        return {success: true, message: "Users created successfully"};
    }
    
    remote function ListAvailableCars(CarFilter filter) returns stream<Car, error?> {
        Car[] availableCars = carInventory.toArray().filter(car => car.status == "AVAILABLE");
        
        if filter.filter_text != "" {
            availableCars = availableCars.filter(car => 
                car.make.toLowerAscii().includes(filter.filter_text.toLowerAscii()) ||
                car.model.toLowerAscii().includes(filter.filter_text.toLowerAscii())
            );
        }
        
        if filter.year != 0 {
            availableCars = availableCars.filter(car => car.year == filter.year);
        }
        
        io:println("Listing available cars: ", availableCars.length());
        return availableCars.toStream();
    }
}

public function main() returns error? {
    log:printInfo("Car Rental gRPC server started on port 9090");
}