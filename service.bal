import ballerina/http;
import ballerina/time;
import ballerina/log;

// Data structures
public type Asset record {
    string assetTag;
    string name;
    string faculty;
    string department;
    string status; // ACTIVE, UNDER_REPAIR, DISPOSED
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
    string frequency; // QUARTERLY, YEARLY, MONTHLY
    string nextDueDate;
    string description;
};

public type WorkOrder record {
    string workOrderId;
    string description;
    string status; // OPEN, IN_PROGRESS, CLOSED
    string createdDate;
    map<Task> tasks;
};

public type Task record {
    string taskId;
    string description;
    string status; // PENDING, COMPLETED
    string assignedTo;
};

// In-memory database using a table
table<Asset> key(assetTag) assetsTable = table [];

// Alternative map implementation (comment out table above and uncomment below if needed)
// map<Asset> assetsDatabase = {};

// Service configuration
@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowCredentials: false,
        allowHeaders: ["*"],
        allowMethods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    }
}
service /api/v1 on new http:Listener(8080) {

    // Create a new asset
    resource function post assets(@http:Payload Asset asset) returns http:Response {
        http:Response response = new;
        
        // Check if asset already exists
        Asset|error existingAsset = assetsTable[asset.assetTag];
        if existingAsset is Asset {
            response.statusCode = 409;
            response.setJsonPayload({"error": "Asset with tag " + asset.assetTag + " already exists"});
            return response;
        }
        
        // Add asset to table
        error? result = assetsTable.add(asset);
        if result is error {
            response.statusCode = 500;
            response.setJsonPayload({"error": "Failed to create asset: " + result.message()});
            return response;
        }
        
        response.statusCode = 201;
        response.setJsonPayload(asset);
        log:printInfo("Asset created: " + asset.assetTag);
        return response;
    }

    // Get all assets
    resource function get assets() returns http:Response {
        http:Response response = new;
        Asset[] allAssets = assetsTable.toArray();
        
        response.statusCode = 200;
        response.setJsonPayload(allAssets);
        return response;
    }

    // Get asset by tag
    resource function get assets/[string assetTag]() returns http:Response {
        http:Response response = new;
        
        Asset|error asset = assetsTable[assetTag];
        if asset is Asset {
            response.statusCode = 200;
            response.setJsonPayload(asset);
        } else {
            response.statusCode = 404;
            response.setJsonPayload({"error": "Asset not found"});
        }
        return response;
    }

    // Update asset
    resource function put assets/[string assetTag](@http:Payload Asset updatedAsset) returns http:Response {
        http:Response response = new;
        
        Asset|error existingAsset = assetsTable[assetTag];
        if existingAsset is error {
            response.statusCode = 404;
            response.setJsonPayload({"error": "Asset not found"});
            return response;
        }
        
        // Ensure the assetTag matches
        updatedAsset.assetTag = assetTag;
        
        // Remove old and add updated
        _ = assetsTable.remove(assetTag);
        error? result = assetsTable.add(updatedAsset);
        
        if result is error {
            response.statusCode = 500;
            response.setJsonPayload({"error": "Failed to update asset"});
            return response;
        }
        
        response.statusCode = 200;
        response.setJsonPayload(updatedAsset);
        log:printInfo("Asset updated: " + assetTag);
        return response;
    }

    // Delete asset
    resource function delete assets/[string assetTag]() returns http:Response {
        http:Response response = new;
        
        Asset|error removedAsset = assetsTable.remove(assetTag);
        if removedAsset is Asset {
            response.statusCode = 200;
            response.setJsonPayload({"message": "Asset deleted successfully"});
            log:printInfo("Asset deleted: " + assetTag);
        } else {
            response.statusCode = 404;
            response.setJsonPayload({"error": "Asset not found"});
        }
        return response;
    }

    // Get assets by faculty
    resource function get assets/faculty/[string faculty]() returns http:Response {
        http:Response response = new;
        
        Asset[] facultyAssets = from Asset asset in assetsTable
                               where asset.faculty == faculty
                               select asset;
        
        response.statusCode = 200;
        response.setJsonPayload(facultyAssets);
        return response;
    }

    // Get overdue maintenance items
    resource function get assets/overdue() returns http:Response {
        http:Response response = new;
        Asset[] overdueAssets = [];
        
        time:Utc currentTime = time:utcNow();
        string currentDate = time:utcToString(currentTime)[0:10]; // YYYY-MM-DD format
        
        foreach Asset asset in assetsTable {
            boolean hasOverdue = false;
            foreach Schedule schedule in asset.schedules {
                if schedule.nextDueDate < currentDate {
                    hasOverdue = true;
                    break;
                }
            }
            if hasOverdue {
                overdueAssets.push(asset);
            }
        }
        
        response.statusCode = 200;
        response.setJsonPayload(overdueAssets);
        return response;
    }

    // Add component to asset
    resource function post assets/[string assetTag]/components(@http:Payload Component component) returns http:Response {
        http:Response response = new;
        
        Asset|error asset = assetsTable[assetTag];
        if asset is error {
            response.statusCode = 404;
            response.setJsonPayload({"error": "Asset not found"});
            return response;
        }
        
        // Add component
        asset.components[component.componentId] = component;
        
        // Update asset in table
        _ = assetsTable.remove(assetTag);
        error? result = assetsTable.add(asset);
        
        if result is error {
            response.statusCode = 500;
            response.setJsonPayload({"error": "Failed to add component"});
            return response;
        }
        
        response.statusCode = 201;
        response.setJsonPayload(component);
        log:printInfo("Component added to asset: " + assetTag);
        return response;
    }

    // Remove component from asset
    resource function delete assets/[string assetTag]/components/[string componentId]() returns http:Response {
        http:Response response = new;
        
        Asset|error asset = assetsTable[assetTag];
        if asset is error {
            response.statusCode = 404;
            response.setJsonPayload({"error": "Asset not found"});
            return response;
        }
        
        // Remove component
        if asset.components.hasKey(componentId) {
            _ = asset.components.remove(componentId);
            
            // Update asset in table
            _ = assetsTable.remove(assetTag);
            error? result = assetsTable.add(asset);
            
            if result is error {
                response.statusCode = 500;
                response.setJsonPayload({"error": "Failed to remove component"});
                return response;
            }
            
            response.statusCode = 200;
            response.setJsonPayload({"message": "Component removed successfully"});
            log:printInfo("Component removed from asset: " + assetTag);
        } else {
            response.statusCode = 404;
            response.setJsonPayload({"error": "Component not found"});
        }
        return response;
    }

    // Add schedule to asset
    resource function post assets/[string assetTag]/schedules(@http:Payload Schedule schedule) returns http:Response {
        http:Response response = new;
        
        Asset|error asset = assetsTable[assetTag];
        if asset is error {
            response.statusCode = 404;
            response.setJsonPayload({"error": "Asset not found"});
            return response;
        }
        
        // Add schedule
        asset.schedules[schedule.scheduleId] = schedule;
        
        // Update asset in table
        _ = assetsTable.remove(assetTag);
        error? result = assetsTable.add(asset);
        
        if result is error {
            response.statusCode = 500;
            response.setJsonPayload({"error": "Failed to add schedule"});
            return response;
        }
        
        response.statusCode = 201;
        response.setJsonPayload(schedule);
        log:printInfo("Schedule added to asset: " + assetTag);
        return response;
    }

    // Remove schedule from asset
    resource function delete assets/[string assetTag]/schedules/[string scheduleId]() returns http:Response {
        http:Response response = new;
        
        Asset|error asset = assetsTable[assetTag];
        if asset is error {
            response.statusCode = 404;
            response.setJsonPayload({"error": "Asset not found"});
            return response;
        }
        
        // Remove schedule
        if asset.schedules.hasKey(scheduleId) {
            _ = asset.schedules.remove(scheduleId);
            
            // Update asset in table
            _ = assetsTable.remove(assetTag);
            error? result = assetsTable.add(asset);
            
            if result is error {
                response.statusCode = 500;
                response.setJsonPayload({"error": "Failed to remove schedule"});
                return response;
            }
            
            response.statusCode = 200;
            response.setJsonPayload({"message": "Schedule removed successfully"});
            log:printInfo("Schedule removed from asset: " + assetTag);
        } else {
            response.statusCode = 404;
            response.setJsonPayload({"error": "Schedule not found"});
        }
        return response;
    }

    // Add work order to asset
    resource function post assets/[string assetTag]/workorders(@http:Payload WorkOrder workOrder) returns http:Response {
        http:Response response = new;
        
        Asset|error asset = assetsTable[assetTag];
        if asset is error {
            response.statusCode = 404;
            response.setJsonPayload({"error": "Asset not found"});
            return response;
        }
        
        // Add work order
        asset.workOrders[workOrder.workOrderId] = workOrder;
        
        // Update asset in table
        _ = assetsTable.remove(assetTag);
        error? result = assetsTable.add(asset);
        
        if result is error {
            response.statusCode = 500;
            response.setJsonPayload({"error": "Failed to add work order"});
            return response;
        }
        
        response.statusCode = 201;
        response.setJsonPayload(workOrder);
        log:printInfo("Work order added to asset: " + assetTag);
        return response;
    }

    // Update work order status
    resource function put assets/[string assetTag]/workorders/[string workOrderId](@http:Payload WorkOrder updatedWorkOrder) returns http:Response {
        http:Response response = new;
        
        Asset|error asset = assetsTable[assetTag];
        if asset is error {
            response.statusCode = 404;
            response.setJsonPayload({"error": "Asset not found"});
            return response;
        }
        
        if asset.workOrders.hasKey(workOrderId) {
            updatedWorkOrder.workOrderId = workOrderId;
            asset.workOrders[workOrderId] = updatedWorkOrder;
            
            // Update asset in table
            _ = assetsTable.remove(assetTag);
            error? result = assetsTable.add(asset);
            
            if result is error {
                response.statusCode = 500;
                response.setJsonPayload({"error": "Failed to update work order"});
                return response;
            }
            
            response.statusCode = 200;
            response.setJsonPayload(updatedWorkOrder);
            log:printInfo("Work order updated: " + workOrderId);
        } else {
            response.statusCode = 404;
            response.setJsonPayload({"error": "Work order not found"});
        }
        return response;
    }

    // Add task to work order
    resource function post assets/[string assetTag]/workorders/[string workOrderId]/tasks(@http:Payload Task task) returns http:Response {
        http:Response response = new;
        
        Asset|error asset = assetsTable[assetTag];
        if asset is error {
            response.statusCode = 404;
            response.setJsonPayload({"error": "Asset not found"});
            return response;
        }
        
        if asset.workOrders.hasKey(workOrderId) {
            asset.workOrders[workOrderId].tasks[task.taskId] = task;
            
            // Update asset in table
            _ = assetsTable.remove(assetTag);
            error? result = assetsTable.add(asset);
            
            if result is error {
                response.statusCode = 500;
                response.setJsonPayload({"error": "Failed to add task"});
                return response;
            }
            
            response.statusCode = 201;
            response.setJsonPayload(task);
            log:printInfo("Task added to work order: " + workOrderId);
        } else {
            response.statusCode = 404;
            response.setJsonPayload({"error": "Work order not found"});
        }
        return response;
    }

    // Remove task from work order
    resource function delete assets/[string assetTag]/workorders/[string workOrderId]/tasks/[string taskId]() returns http:Response {
        http:Response response = new;
        
        Asset|error asset = assetsTable[assetTag];
        if asset is error {
            response.statusCode = 404;
            response.setJsonPayload({"error": "Asset not found"});
            return response;
        }
        
        if asset.workOrders.hasKey(workOrderId) && asset.workOrders[workOrderId].tasks.hasKey(taskId) {
            _ = asset.workOrders[workOrderId].tasks.remove(taskId);
            
            // Update asset in table
            _ = assetsTable.remove(assetTag);
            error? result = assetsTable.add(asset);
            
            if result is error {
                response.statusCode = 500;
                response.setJsonPayload({"error": "Failed to remove task"});
                return response;
            }
            
            response.statusCode = 200;
            response.setJsonPayload({"message": "Task removed successfully"});
            log:printInfo("Task removed: " + taskId);
        } else {
            response.statusCode = 404;
            response.setJsonPayload({"error": "Work order or task not found"});
        }
        return response;
    }
}