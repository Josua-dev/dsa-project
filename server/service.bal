import ballerina/http;
import ballerina/time;
import ballerina/log;

// Data types
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
    string frequency; // "QUARTERLY", "YEARLY", "MONTHLY"
    string nextDueDate;
    string description;
};

public type WorkOrder record {
    string workOrderId;
    string status; // "OPEN", "IN_PROGRESS", "CLOSED"
    string description;
    string dateOpened;
    string dateClosed?;
    map<Task> tasks;
};

public type Task record {
    string taskId;
    string description;
    string status; // "PENDING", "COMPLETED"
};

// In-memory database
map<Asset> assetDatabase = {};

// Service configuration
listener http:Listener httpListener = new(8080);

service /assets on httpListener {

    // Create a new asset
    resource function post .(Asset asset) returns Asset|error {
        if assetDatabase.hasKey(asset.assetTag) {
            return error("Asset with tag " + asset.assetTag + " already exists");
        }
        assetDatabase[asset.assetTag] = asset;
        log:printInfo("Asset created: " + asset.assetTag);
        return asset;
    }

    // Get all assets
    resource function get .() returns Asset[] {
        return assetDatabase.toArray();
    }

    // Get asset by tag
    resource function get [string assetTag]() returns Asset|error {
        if assetDatabase.hasKey(assetTag) {
            return assetDatabase.get(assetTag);
        }
        return error("Asset not found");
    }

    // Update asset
    resource function put [string assetTag](Asset asset) returns Asset|error {
        if !assetDatabase.hasKey(assetTag) {
            return error("Asset not found");
        }
        asset.assetTag = assetTag; // Ensure tag consistency
        assetDatabase[assetTag] = asset;
        log:printInfo("Asset updated: " + assetTag);
        return asset;
    }

    // Delete asset
    resource function delete [string assetTag]() returns http:Ok|error {
        if !assetDatabase.hasKey(assetTag) {
            return error("Asset not found");
        }
        _ = assetDatabase.remove(assetTag);
        log:printInfo("Asset deleted: " + assetTag);
        return http:OK;
    }

    // Get assets by faculty
    resource function get faculty/[string faculty]() returns Asset[] {
        Asset[] facultyAssets = [];
        foreach Asset asset in assetDatabase {
            if asset.faculty == faculty {
                facultyAssets.push(asset);
            }
        }
        return facultyAssets;
    }

    // Get overdue maintenance schedules
    resource function get overdue() returns Asset[] {
        Asset[] overdueAssets = [];
        string currentDate = time:utcToString(time:utcNow());
        
        foreach Asset asset in assetDatabase {
            foreach Schedule schedule in asset.schedules {
                // Simple date comparison (in real implementation, use proper date parsing)
                if schedule.nextDueDate < currentDate {
                    overdueAssets.push(asset);
                    break; // Don't add the same asset multiple times
                }
            }
        }
        return overdueAssets;
    }

    // Component management
    resource function post [string assetTag]/components(Component component) returns Component|error {
        if !assetDatabase.hasKey(assetTag) {
            return error("Asset not found");
        }
        Asset asset = assetDatabase.get(assetTag);
        asset.components[component.componentId] = component;
        assetDatabase[assetTag] = asset;
        log:printInfo("Component added to asset: " + assetTag);
        return component;
    }

    resource function delete [string assetTag]/components/[string componentId]() returns http:Ok|error {
        if !assetDatabase.hasKey(assetTag) {
            return error("Asset not found");
        }
        Asset asset = assetDatabase.get(assetTag);
        if !asset.components.hasKey(componentId) {
            return error("Component not found");
        }
        _ = asset.components.remove(componentId);
        assetDatabase[assetTag] = asset;
        log:printInfo("Component removed from asset: " + assetTag);
        return http:OK;
    }

    // Schedule management
    resource function post [string assetTag]/schedules(Schedule schedule) returns Schedule|error {
        if !assetDatabase.hasKey(assetTag) {
            return error("Asset not found");
        }
        Asset asset = assetDatabase.get(assetTag);
        asset.schedules[schedule.scheduleId] = schedule;
        assetDatabase[assetTag] = asset;
        log:printInfo("Schedule added to asset: " + assetTag);
        return schedule;
    }

    resource function delete [string assetTag]/schedules/[string scheduleId]() returns http:Ok|error {
        if !assetDatabase.hasKey(assetTag) {
            return error("Asset not found");
        }
        Asset asset = assetDatabase.get(assetTag);
        if !asset.schedules.hasKey(scheduleId) {
            return error("Schedule not found");
        }
        _ = asset.schedules.remove(scheduleId);
        assetDatabase[assetTag] = asset;
        log:printInfo("Schedule removed from asset: " + assetTag);
        return http:OK;
    }

    // Work order management
    resource function post [string assetTag]/workorders(WorkOrder workOrder) returns WorkOrder|error {
        if !assetDatabase.hasKey(assetTag) {
            return error("Asset not found");
        }
        Asset asset = assetDatabase.get(assetTag);
        asset.workOrders[workOrder.workOrderId] = workOrder;
        assetDatabase[assetTag] = asset;
        log:printInfo("Work order added to asset: " + assetTag);
        return workOrder;
    }

    resource function put [string assetTag]/workorders/[string workOrderId](WorkOrder workOrder) returns WorkOrder|error {
        if !assetDatabase.hasKey(assetTag) {
            return error("Asset not found");
        }
        Asset asset = assetDatabase.get(assetTag);
        if !asset.workOrders.hasKey(workOrderId) {
            return error("Work order not found");
        }
        workOrder.workOrderId = workOrderId;
        asset.workOrders[workOrderId] = workOrder;
        assetDatabase[assetTag] = asset;
        log:printInfo("Work order updated: " + workOrderId);
        return workOrder;
    }

    // Task management
    resource function post [string assetTag]/workorders/[string workOrderId]/tasks(Task task) returns Task|error {
        if !assetDatabase.hasKey(assetTag) {
            return error("Asset not found");
        }
        Asset asset = assetDatabase.get(assetTag);
        if !asset.workOrders.hasKey(workOrderId) {
            return error("Work order not found");
        }
        WorkOrder workOrder = asset.workOrders.get(workOrderId);
        workOrder.tasks[task.taskId] = task;
        asset.workOrders[workOrderId] = workOrder;
        assetDatabase[assetTag] = asset;
        log:printInfo("Task added to work order: " + workOrderId);
        return task;
    }

    resource function delete [string assetTag]/workorders/[string workOrderId]/tasks/[string taskId]() returns http:Ok|error {
        if !assetDatabase.hasKey(assetTag) {
            return error("Asset not found");
        }
        Asset asset = assetDatabase.get(assetTag);
        if !asset.workOrders.hasKey(workOrderId) {
            return error("Work order not found");
        }
        WorkOrder workOrder = asset.workOrders.get(workOrderId);
        if !workOrder.tasks.hasKey(taskId) {
            return error("Task not found");
        }
        _ = workOrder.tasks.remove(taskId);
        asset.workOrders[workOrderId] = workOrder;
        assetDatabase[assetTag] = asset;
        log:printInfo("Task removed: " + taskId);
        return http:OK;
    }
}