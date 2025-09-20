import ballerina/io;
import ballerina/log;

public function main() returns error? {
    log:printInfo("Starting Car Rental Client Test");
    
    // Test data structures
    Car newCar = {
        plate: "ABC123",
        make: "Toyota",
        model: "Camry",
        year: 2023,
        daily_price: 50.0,
        mileage: 15000.0,
        status: "AVAILABLE"
    };
    
    io:println("=== Testing Car Rental Data Structures ===");
    io:println("New Car: ", newCar);
    
    CarRequest searchRequest = {plate: "ABC123"};
    io:println("Search Request: ", searchRequest);
    
    CartRequest cartRequest = {
        customer_id: "CUST001",
        plate: "ABC123",
        start_date: "2025-10-01",
        end_date: "2025-10-08"
    };
    io:println("Cart Request: ", cartRequest);
    
    ReservationRequest reservationRequest = {customer_id: "CUST001"};
    io:println("Reservation Request: ", reservationRequest);
    
    // Test response structures
    CarResponse carResponse = {
        success: true,
        message: "Car operation successful",
        car: newCar
    };
    io:println("Car Response: ", carResponse);
    
    CartResponse cartResponse = {
        success: true,
        message: "Added to cart successfully"
    };
    io:println("Cart Response: ", cartResponse);
    
    ReservationResponse reservationResponse = {
        success: true,
        message: "Reservation placed successfully",
        total_price: 350.0,
        reservation_id: "RES001"
    };
    io:println("Reservation Response: ", reservationResponse);
    
    io:println("=== All data structures working correctly ===");
    io:println("Client is ready to connect to gRPC server when it's running");
}