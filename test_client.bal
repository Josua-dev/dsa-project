import ballerina/http;
import ballerina/io;
import ballerina/log;

// HTTP client for testing
http:Client testClient = check new ("http://localhost:8080/api/v1");

public function main() returns error? {
    log:printInfo("Asset Management API Test Client");
    
    while true {
        io:println("\n=== Asset Management System ===");
        io:println("1. Create Asset");
        io:println("2. View All Assets");
        io:println("3. View Asset by Tag");
        io:println("4. Update Asset");
        io:println("5. Delete Asset");
        io:println("6. View Assets by Faculty");
        io:println("7. Check Overdue Maintenance");
        io:println("8. Add Component");
        io:println("9. Add Schedule");
        io:println("10. Add Work Order");
        io:println("0. Exit");
        io:println("Choose an option: ");
        
        string choice = io:readln();
        
        match choice.trim() {
            "1" => { check createAsset(); }
            "2" => { check viewAllAssets(); }
            "3" => { check viewAssetByTag(); }
            "4" => { check updateAsset(); }
            "5" => { check deleteAsset(); }
            "6" => { check viewAssetsByFaculty(); }
            "7" => { check checkOverdue(); }
            "8" => { check addComponent(); }
            "9" => { check addSchedule(); }
            "10" => { check addWorkOrder(); }
            "0" => { 
                io:println("Goodbye!");
                break;
            }
            _ => { io:println("Invalid choice. Please try again."); }
        }
    }
}

function createAsset() returns error? {
    io:println("\n--- Create New Asset ---");
    io:print("Asset Tag: ");
    string assetTag = io:readln().trim();
    
    io:print("Asset Name: ");
    string name = io:readln().trim();
    
    io:print("Faculty: ");
    string faculty = io:readln().trim();
    
    io:print("Department: ");
    string department = io:readln().trim();
    
    io:print("Status (ACTIVE/UNDER_REPAIR/DISPOSED): ");
    string status = io:readln().trim();
    
    io:print("Acquired Date (YYYY-MM-DD): ");
    string acquiredDate = io:readln().trim();
    
    json asset = {
        "assetTag": assetTag,
        "name": name,
        "faculty": faculty,
        "department": department,
        "status": status,
        "acquiredDate": acquiredDate,
        "components": {},
        "schedules": {},
        "workOrders": {}
    };
    
    http:Response response = check testClient->post("/assets", asset);
    json responsePayload = check response.getJsonPayload();
    
    io:println("Response Status: " + response.statusCode.toString());
    io:println("Response: " + responsePayload.toJsonString());
}

function viewAllAssets() returns error? {
    io:println("\n--- All Assets ---");
    
    http:Response response = check testClient->get("/assets");
    json responsePayload = check response.getJsonPayload();
    
    io:println("Response Status: " + response.statusCode.toString());
    io:println("Assets:");
    io:println(responsePayload.toJsonString());
}

function viewAssetByTag() returns error? {
    io:println("\n--- View Asset by Tag ---");
    io:print("Enter Asset Tag: ");
    string assetTag = io:readln().trim();
    
    http:Response response = check testClient->get("/assets/" + assetTag);
    json responsePayload = check response.getJsonPayload();
    
    io:println("Response Status: " + response.statusCode.toString());
    io:println("Asset:");
    io:println(responsePayload.toJsonString());
}

function updateAsset() returns error? {
    io:println("\n--- Update Asset ---");
    io:print("Asset Tag to update: ");
    string assetTag = io:readln