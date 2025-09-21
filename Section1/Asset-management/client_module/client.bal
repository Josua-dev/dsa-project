import ballerina/http;
import ballerina/io;

type ClientAsset record {
    string assetTag;
    string name;
    string faculty;
    string department;
    string status;
    string acquiredDate;
};

// Nested types matching API
type Component record {
    string name;
    string? description;
};

type Schedule record {
    string name;
    string frequency;
    string nextDueDate;
};

public function main() returns error? {
    http:Client httpClient = check new ("http://localhost:9090");

    // Add asset
    ClientAsset asset = {
        assetTag: "EQ-001",
        name: "3D Printer",
        faculty: "Computing & Informatics",
        department: "Software Engineering",
        status: "ACTIVE",
        acquiredDate: "2024-03-10"
    };

    json postResp = check httpClient->post("/assets/addAsset", asset, headers = {"Content-Type": "application/json"});
    io:println("POST Response: ", postResp.toJsonString());

    // View all assets
    json allAssets = check httpClient->get("/assets/allAssets");
    io:println("All assets: ", allAssets.toJsonString());

    // Filter by faculty
    json csAssets = check httpClient->get("/assets/byFaculty/Computing & Informatics");
    io:println("CS Faculty Assets: ", csAssets.toJsonString());

    // Add component
    Component comp = { name: "Motor", description: "Printer motor" };
    json compResp = check httpClient->post("/assets/addComponent/EQ-001", comp, headers = {"Content-Type": "application/json"});
    io:println("Add Component Response: ", compResp.toJsonString());

    // Add schedule
    Schedule sched = { name: "Quarterly Check", frequency: "Quarterly", nextDueDate: "2024-01-01" };
    json schedResp = check httpClient->post("/assets/addSchedule/EQ-001", sched, headers = {"Content-Type": "application/json"});
    io:println("Add Schedule Response: ", schedResp.toJsonString());

    // Check overdue schedules
    json overdue = check httpClient->get("/assets/overdue");
    io:println("Overdue Assets: ", overdue.toJsonString());

    // Delete asset
    json delResp = check httpClient->delete("/assets/remove/EQ-001", headers = {"Content-Type": "application/json"});
    io:println("Delete Response: ", delResp.toJsonString());
}
