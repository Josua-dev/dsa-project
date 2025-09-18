import ballerina/grpc;
import stubs.carrental;
import ballerina/io;

grpc:Client carClient = check new("http://localhost:9090/carrental");

public function main() returns error? {

    // Add a car
    carrental:Car car = { numberPlate: "N12345W", make: "Toyota", model: "Corolla", year: 2022,
                          dailyPrice: 50, mileage: 10000, status: carrental:CarStatus.AVAILABLE };
    var addCarRes = carClient->addCar({ car: car });
    io:println("Added car: ", addCarRes.numberPlate);

    // List available cars
    stream<carrental:Car, grpc:Error?> carStream = carClient->listAvailableCars({ filter: "" });
    check from var c in carStream do {
        io:println("Available car: ", c.make, " ", c.model);
    };

    // Create a customer
    var customerRes = carClient->createCustomer({ customers: [{ customerId: "C1", fullName: "Alice", phoneNumber: "08112345", role: "Customer" }] });
    io:println(customerRes.message);

    // Add to cart
    carrental:CartItem item = { numberPlate: "N1234W", startDate: "2025-09-20", endDate: "2025-09-25" };
    check carClient->addToCart({ customerId: "C1", item: item });

    // Place reservation
    var reservationRes = carClient->placeReservation({ customerId: "C1" });
    io:println("Reservation ID: ", reservationRes.reservation.reservationId, ", Total: $", reservationRes.reservation.totalPrice);
}
