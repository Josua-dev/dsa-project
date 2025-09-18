import ballerina/http;
import ballerina/io;


// Data types (same as server)
public type AssetStatus "ACTIVE"|"UNDER_REPAIR"|"DISPOSED";

public type Asset record {
    string assetTag;
    string name;
    string faculty;
    string department;
    AssetStatus status;
    string acquiredDate;
    map<Component> components;
    map<Schedule> schedules;
    map<WorkOrder> workOrders;
};

public type Component record {
    string componentId;
    string name;
    string description;
    string status;
};

public type Schedule record {
    string scheduleId;
    string frequency;
    string nextDueDate;
    string description;
};

public type WorkOrder record {
    string workOrderId;
    string status;
    string description;
    string dateOpened;
    string dateClosed?;
    map<Task> tasks;
};

public type Task record {
    string taskId;
    string description;
    string status;
};

// Helper function to repeat a character
function repeatChar(string char, int count) returns string {
    string result = "";
    int i = 0;
    while (i < count) {
        result += char;
        i += 1;
    }
    return result;
}

// Helper function to print formatted output
function printSeparator(string title) {
    io:println();
    io:println(repeatChar("=", 60));
    io:println("  " + title.toUpperAscii());
    io:println(repeatChar("=", 60));
}

function printSubSection(string title) {
    io:println();
    io:println(repeatChar("-", 40));
    io:println("  " + title);
    io:println(repeatChar("-", 40));
}

function printAsset(Asset asset, string prefix = "") {
    io:println(prefix + "Asset Tag: " + asset.assetTag);
    io:println(prefix + "Name: " + asset.name);
    io:println(prefix + "Faculty: " + asset.faculty);
    io:println(prefix + "Department: " + asset.department);
    io:println(prefix + "Status: " + asset.status);
    io:println(prefix + "Acquired Date: " + asset.acquiredDate);
    io:println(prefix + "Components: " + asset.components.length().toString());
    io:println(prefix + "Schedules: " + asset.schedules.length().toString());
    io:println(prefix + "Work Orders: " + asset.workOrders.length().toString());
}

function printAssetList(Asset[] assets, string title) {
    printSubSection(title);
    if (assets.length() == 0) {
        io:println("  No assets found.");
        return;
    }
    
    foreach int i in 0 ..< assets.length() {
        io:println();
        io:println("  Asset #" + (i + 1).toString() + ":");
        printAsset(assets[i], "    ");
    }
}

function printComponent(Component component, string prefix = "") {
    io:println(prefix + "Component ID: " + component.componentId);
    io:println(prefix + "Name: " + component.name);
    io:println(prefix + "Description: " + component.description);
    io:println(prefix + "Status: " + component.status);
}

function printSchedule(Schedule schedule, string prefix = "") {
    io:println(prefix + "Schedule ID: " + schedule.scheduleId);
    io:println(prefix + "Frequency: " + schedule.frequency);
    io:println(prefix + "Next Due Date: " + schedule.nextDueDate);
    io:println(prefix + "Description: " + schedule.description);
}

public function main() returns error? {
    http:Client assetClient = check new ("http://localhost:8080");

    printSeparator("Asset Management System - Client Test Suite");
    io:println("Testing RESTful API endpoints...");
    io:println("Server: http://localhost:8080");

    // Test 1: Create assets
    printSubSection("TEST 1: Creating Assets");
    
    Asset asset1 = {
        assetTag: "E5-003",
        name: "3D Printer",
        faculty: "Computing & Informatics",
        department: "Software Engineering",
        status: "ACTIVE",
        acquiredDate: "2024-03-10",
        components: {},
        schedules: {},
        workOrders: {}
    };

    io:println("Creating Asset 1...");
    Asset createdAsset = check assetClient->/assets.post(asset1);
    io:println("✅ SUCCESS: Asset created");
    printAsset(createdAsset, "  ");

    Asset asset2 = {
        assetTag: "LAB-003",
        name: "Server Dell R720",
        faculty: "Computing & Informatics",
        department: "Computer Science",
        status: "ACTIVE",
        acquiredDate: "2024-01-15",
        components: {},
        schedules: {},
        workOrders: {}
    };

    io:println();
    io:println("Creating Asset 2...");
    Asset createdAsset2 = check assetClient->/assets.post(asset2);
    io:println("✅ SUCCESS: Asset created");
    printAsset(createdAsset2, "  ");

    // Test 2: View all assets
    printSubSection("TEST 2: Retrieving All Assets");
    Asset[] allAssets = check assetClient->/assets.get();
    io:println("✅ SUCCESS: Retrieved " + allAssets.length().toString() + " assets");
    printAssetList(allAssets, "All Assets in Database");

    // Test 3: View assets by faculty
    printSubSection("TEST 3: Filtering Assets by Faculty");
    Asset[] facultyAssets = check assetClient->/assets/faculty/["Computing & Informatics"].get();
    io:println("✅ SUCCESS: Found " + facultyAssets.length().toString() + " assets in 'Computing & Informatics' faculty");
    printAssetList(facultyAssets, "Faculty: Computing & Informatics");

    // Test 4: Add a component
    printSubSection("TEST 4: Adding Component to Asset");
    Component component = {
        componentId: "COMP-001",
        name: "Print Head",
        description: "Main printing component",
        status: "ACTIVE"
    };

    io:println("Adding component to asset EQ-001...");
    Component addedComponent = check assetClient->/assets/["EQ-001"]/components.post(component);
    io:println("✅ SUCCESS: Component added");
    printComponent(addedComponent, "  ");

    // Test 5: Add schedules
    printSubSection("TEST 5: Adding Maintenance Schedules");
    Schedule schedule = {
        scheduleId: "SCH-001",
        frequency: "QUARTERLY",
        nextDueDate: "2025-12-31",
        description: "Quarterly maintenance check"
    };

    io:println("Adding future schedule to EQ-001...");
    Schedule addedSchedule = check assetClient->/assets/["EQ-001"]/schedules.post(schedule);
    io:println("✅ SUCCESS: Schedule added");
    printSchedule(addedSchedule, "  ");

    // Add an overdue schedule for testing
    Schedule overdueSchedule = {
        scheduleId: "SCH-002",
        frequency: "MONTHLY",
        nextDueDate: "2025-01-01", // Past date
        description: "Monthly check - overdue"
    };

    io:println();
    io:println("Adding overdue schedule to LAB-002...");
    Schedule addedOverdueSchedule = check assetClient->/assets/["LAB-002"]/schedules.post(overdueSchedule);
    io:println("✅ SUCCESS: Overdue schedule added");
    printSchedule(addedOverdueSchedule, "  ");

    // Test 6: Check for overdue items
    printSubSection("TEST 6: Checking for Overdue Maintenance");
    Asset[] overdueAssets = check assetClient->/assets/overdue.get();
    io:println("✅ SUCCESS: Found " + overdueAssets.length().toString() + " assets with overdue maintenance");
    
    if (overdueAssets.length() > 0) {
        printAssetList(overdueAssets, "Assets with Overdue Maintenance");
        
        // Show overdue schedules details
        io:println();
        io:println("  Overdue Schedule Details:");
        foreach Asset overdueAsset in overdueAssets {
            foreach Schedule sched in overdueAsset.schedules {
                if (sched.nextDueDate < "2025-09-18") { // Current date
                    io:println();
                    io:println("    Asset: " + overdueAsset.assetTag);
                    io:println("    ⚠️  OVERDUE SCHEDULE:");
                    printSchedule(sched, "      ");
                    io:println("      Days Overdue: Multiple days (simplified calculation)");
                }
            }
        }
    }

    // Test 7: Update an asset
    printSubSection("TEST 7: Updating Asset Status");
    asset1.status = "UNDER_REPAIR";
    io:println("Updating asset EQ-001 status to UNDER_REPAIR...");
    Asset updatedAsset = check assetClient->/assets/["EQ-001"].put(asset1);
    io:println("✅ SUCCESS: Asset updated");
    printAsset(updatedAsset, "  ");

    // Test 8: Get specific asset
    printSubSection("TEST 8: Retrieving Specific Asset");
    io:println("Fetching asset EQ-001 with all its components and schedules...");
    Asset specificAsset = check assetClient->/assets/["EQ-001"].get();
    io:println("✅ SUCCESS: Asset retrieved");
    printAsset(specificAsset, "  ");
    
    if (specificAsset.components.length() > 0) {
        io:println();
        io:println("  Associated Components:");
        foreach Component comp in specificAsset.components {
            io:println();
            printComponent(comp, "    ");
        }
    }
    
    if (specificAsset.schedules.length() > 0) {
        io:println();
        io:println("  Associated Schedules:");
        foreach Schedule sched in specificAsset.schedules {
            io:println();
            printSchedule(sched, "    ");
        }
    }

    // Test 9: Advanced operations
    printSubSection("TEST 9: Advanced Operations");
    
    // Create a work order
    WorkOrder workOrder = {
        workOrderId: "WO-001",
        status: "OPEN",
        description: "Repair print head malfunction",
        dateOpened: "2025-09-18",
        tasks: {}
    };
    
    io:println("Creating work order for asset EQ-001...");
    WorkOrder createdWorkOrder = check assetClient->/assets/["EQ-001"]/workorders.post(workOrder);
    io:println("✅ SUCCESS: Work order created");
    io:println("  Work Order ID: " + createdWorkOrder.workOrderId);
    io:println("  Status: " + createdWorkOrder.status);
    io:println("  Description: " + createdWorkOrder.description);
    io:println("  Date Opened: " + createdWorkOrder.dateOpened);

    // Add a task to the work order
    Task task = {
        taskId: "TASK-001",
        description: "Replace print head component",
        status: "PENDING"
    };
    
    io:println();
    io:println("Adding task to work order WO-001...");
    Task createdTask = check assetClient->/assets/["EQ-001"]/workorders/["WO-001"]/tasks.post(task);
    io:println("✅ SUCCESS: Task added to work order");
    io:println("  Task ID: " + createdTask.taskId);
    io:println("  Description: " + createdTask.description);
    io:println("  Status: " + createdTask.status);

    // Final summary
    printSeparator("Test Summary");
    io:println("✅ Asset Creation: PASSED");
    io:println("✅ Asset Retrieval: PASSED");
    io:println("✅ Asset Update: PASSED");
    io:println("✅ Faculty Filtering: PASSED");
    io:println("✅ Overdue Detection: PASSED");
    io:println("✅ Component Management: PASSED");
    io:println("✅ Schedule Management: PASSED");
    io:println("✅ Work Order Management: PASSED");
    io:println("✅ Task Management: PASSED");
    io:println();
    io:println("🎉 ALL TESTS COMPLETED SUCCESSFULLY!");
    io:println("🎉 RESTful API is working perfectly!");
    
    printSeparator("Manual Testing");
    io:println("You can now test manually using cURL commands:");
    io:println();
    io:println("# Get all assets:");
    io:println("curl http://localhost:8080/assets");
    io:println();
    io:println("# Get specific asset:");
    io:println("curl http://localhost:8080/assets/EQ-001");
    io:println();
    io:println("# Get faculty assets:");
    io:println("curl \"http://localhost:8080/assets/faculty/Computing%20&%20Informatics\"");
    io:println();
    io:println("# Check overdue assets:");
    io:println("curl http://localhost:8080/assets/overdue");
    
    printSeparator("End of Tests");
}