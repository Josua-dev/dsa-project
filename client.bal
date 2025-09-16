import ballerina/http;
import ballerina/io;
import ballerina/log;

// HTTP client configuration
http:Client assetClient = check new ("http://localhost:8080/api/v1");

public function main() returns error? {
    log:printInfo("Starting Asset Management Client Demo");
    
    // Demo 1: Create assets
    check createSampleAssets();
    
    // Demo 2: View all assets
    check viewAllAssets();
    
    // Demo 3: View assets by faculty
    check viewAssetsByFaculty("Computing & Informatics");
    
    // Demo 4: Add components and schedules
    check addComponentsAndSchedules();
    
    // Demo 5: Check for overdue maintenance
    check checkOverdueMaintenance();
    
    // Demo 6: Update an asset
    check updateAsset();
    
    log:printInfo("Asset Management Client Demo completed successfully");
}

function createSampleAssets() returns error? {
    log:printInfo("Creating sample assets...");
    
    // Asset 1: 3D Printer
    json asset1 = {
        "assetTag": "EQ-001",
        "name": "3D Printer",
        "faculty": "Computing & Informatics",
        "department": "Software Engineering",
        "status": "ACTIVE",
        "acquiredDate": "2024-03-10",
        "components": {},
        "schedules": {},
        "workOrders": {}
    };
    
    // Asset 2: Server
    json asset2 = {
        "assetTag": "SV-001", 
        "name": "Dell PowerEdge Server",
        "faculty": "Computing & Informatics",
        "department": "Computer Science",
        "status": "ACTIVE",
        "acquiredDate": "2023-08-15",
        "components": {},
        "schedules": {},
        "workOrders": {}
    };
    
    // Asset 3: Laboratory Equipment
    json asset3 = {
        "assetTag": "LAB-001",
        "name": "Microscope",
        "faculty": "Natural Resources & Spatial Sciences",
        "department": "Biology",
        "status": "ACTIVE",
        "acquiredDate": "2024-01-20",
        "components": {},
        "schedules": {},
        "workOrders": {}
    };
    
    // Create the assets
    http:Response response1 = check assetClient->post("/assets", asset1);
    io:println("Created Asset 1 - Status: " + response1.statusCode.toString());
    
    http:Response response2 = check assetClient->post("/assets", asset2);
    io:println("Created Asset 2 - Status: " + response2.statusCode.toString());
    
    http:Response response3 = check assetClient->post("/assets", asset3);
    io:println("Created Asset 3 - Status: " + response3.statusCode.toString());
    
    io:println("");
}

function viewAllAssets() returns error? {
    log:printInfo("Retrieving all assets...");
    
    http:Response response = check assetClient->get("/assets");
    json responsePayload = check response.getJsonPayload();
    
    io:println("All Assets:");
    io:println(responsePayload.toJsonString());
    io:println("");
}

function viewAssetsByFaculty(string faculty) returns error? {
    log:printInfo("Retrieving assets for faculty: " + faculty);
    
    string encodedFaculty = check http:encode(faculty, "UTF-8");
    http:Response response = check assetClient->get("/assets/faculty/" + encodedFaculty);
    json responsePayload = check response.getJsonPayload();
    
    io:println("Assets for " + faculty + ":");
    io:println(responsePayload.toJsonString());
    io:println("");
}

function addComponentsAndSchedules() returns error? {
    log:printInfo("Adding components and schedules...");
    
    // Add component to 3D Printer
    json component = {
        "componentId": "COMP-001",
        "name": "Print Head",
        "description": "Main printing component",
        "status": "ACTIVE"
    };
    
    http:Response compResponse = check assetClient->post("/assets/EQ-001/components", component);
    io:println("Added component - Status: " + compResponse.statusCode.toString());
    
    // Add maintenance schedule to Server
    json schedule = {
        "scheduleId": "SCH-001",
        "frequency": "QUARTERLY",
        "nextDueDate": "2025-12-01",
        "description": "Quarterly maintenance check"
    };
    
    http:Response schedResponse = check assetClient->post("/assets/SV-001/schedules", schedule);
    io:println("Added schedule - Status: " + schedResponse.statusCode.toString());
    
    // Add an overdue schedule for testing
    json overdueSchedule = {
        "scheduleId": "SCH-002",
        "frequency": "MONTHLY",
        "nextDueDate": "2025-08-01",
        "description": "Monthly maintenance check - OVERDUE"
    };
    
    http:Response overdueResponse = check assetClient->post("/assets/LAB-001/schedules", overdueSchedule);
    io:println("Added overdue schedule - Status: " + overdueResponse.statusCode.toString());
    io:println("");
}

function checkOverdueMaintenance() returns error? {
    log:printInfo("Checking for overdue maintenance...");
    
    http:Response response = check assetClient->get("/assets/overdue");
    json responsePayload = check response.getJsonPayload();
    
    io:println("Overdue Assets:");
    io:println(responsePayload.toJsonString());
    io:println("");
}

function updateAsset() returns error? {
    log:printInfo("Updating asset...");
    
    // Update the 3D Printer status
    json updatedAsset = {
        "assetTag": "EQ-001",
        "name": "3D Printer - Updated",
        "faculty": "Computing & Informatics",
        "department": "Software Engineering",
        "status": "UNDER_REPAIR",
        "acquiredDate": "2024-03-10",
        "components": {
            "COMP-001": {
                "componentId": "COMP-001",
                "name": "Print Head",
                "description": "Main printing component",
                "status": "ACTIVE"
            }
        },
        "schedules": {},
        "workOrders": {}
    };
    
    http:Response response = check assetClient->put("/assets/EQ-001", updatedAsset);
    io:println("Updated asset - Status: " + response.statusCode.toString());
    
    if response.statusCode == 200 {
        json responsePayload = check response.getJsonPayload();
        io:println("Updated Asset:");
        io:println(responsePayload.toJsonString());
    }
    io:println("");
}

// Additional helper functions for interactive testing
function testWorkOrderManagement() returns error? {
    log:printInfo("Testing work order management...");
    
    // Create a work order
    json workOrder = {
        "workOrderId": "WO-001",
        "description": "Fix printer jam",
        "status": "OPEN",
        "createdDate": "2025-09-16",
        "tasks": {}
    };
    
    http:Response woResponse = check assetClient->post("/assets/EQ-001/workorders", workOrder);
    io:println("Created work order - Status: " + woResponse.statusCode.toString());
    
    // Add a task to the work order
    json task = {
        "taskId": "TASK-001",
        "description": "Replace print head",
        "status": "PENDING",
        "assignedTo": "John Doe"
    };
    
    http:Response taskResponse = check assetClient->post("/assets/EQ-001/workorders/WO-001/tasks", task);
    io:println("Added task - Status: " + taskResponse.statusCode.toString());
    
    io:println("");
}