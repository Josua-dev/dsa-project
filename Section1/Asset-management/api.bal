import ballerina/http;
import ballerina/time;

// Component, Schedule, WorkOrder, Task types
type Component record {
    string name;
    string description?;
};

type Schedule record {
    string name;
    string frequency; // e.g., "Quarterly", "Yearly"
    string nextDueDate; // YYYY-MM-DD
};

type Task record {
    string description;
    string status; // "PENDING", "DONE"
};

type WorkOrder record {
    string description;
    string status; // "OPEN", "IN_PROGRESS", "CLOSED"
    Task[] tasks = [];
};

// Asset record with nested structures
type Asset record {
    string assetTag;
    string name;
    string faculty;
    string department;
    string status;
    string acquiredDate;
    map<Component> components = {};
    map<Schedule> schedules = {};
    map<WorkOrder> workOrders = {};
};

map<Asset> assetStore = {};

service /assets on new http:Listener(9090) {

    // GET all assets
    resource function get allAssets() returns Asset[] {
        Asset[] all = [];
        foreach var key in assetStore.keys() {
            Asset? maybe = assetStore[key];
            if maybe is Asset {
                all.push(maybe);
            }
        }
        return all;
    }

    // GET assets by faculty
    resource function get byFaculty/[string faculty]() returns Asset[] {
        Asset[] result = [];
        foreach var entry in assetStore.entries() {
            var [_, a] = entry;
            if a.faculty == faculty {
                result.push(a);
            }
        }
        return result;
    }

    // POST add asset
    resource function post addAsset(@http:Payload Asset newAsset) returns json {
        if assetStore.hasKey(newAsset.assetTag) {
            return { status: "error", message: "Asset already exists", assetTag: newAsset.assetTag };
        }
        assetStore[newAsset.assetTag] = newAsset;
        return { status: "success", message: "Asset added", assetTag: newAsset.assetTag };
    }

    // PUT update asset
    resource function put update/[string assetTag](@http:Payload Asset updatedAsset) returns json {
        if !assetStore.hasKey(assetTag) {
            return { status: "error", message: "Asset not found", assetTag: assetTag };
        }
        assetStore[assetTag] = updatedAsset;
        return { status: "success", message: "Asset updated", assetTag: assetTag };
    }

    // DELETE asset
    resource function delete remove/[string assetTag]() returns json {
        if assetStore.hasKey(assetTag) {
            _ = assetStore.remove(assetTag);
            return { status: "success", message: "Asset deleted", assetTag: assetTag };
        }
        return { status: "error", message: "Asset not found", assetTag: assetTag };
    }

    // GET asset count
    resource function get count() returns json {
        return { status: "success", totalAssets: assetStore.length() };
    }

    // GET overdue schedules
    resource function get overdue() returns Asset[] {
        Asset[] overdueAssets = [];
        string today = time:utcNow().toString().substring(0, 10); // YYYY-MM-DD
        foreach var entry in assetStore.entries() {
            var [_, a] = entry;
            boolean hasOverdue = false;
            foreach var scheduleEntry in a.schedules.entries() {
                var [_, s] = scheduleEntry;
                if s.nextDueDate < today {
                    hasOverdue = true;
                    break;
                }
            }
            if hasOverdue {
                overdueAssets.push(a);
            }
        }
        return overdueAssets;
    }

    // POST add component
    resource function post addComponent/[string assetTag](@http:Payload Component comp) returns json {
        if !assetStore.hasKey(assetTag) {
            return { status: "error", message: "Asset not found", assetTag: assetTag };
        }
        assetStore[assetTag].components[comp.name] = comp;
        return { status: "success", message: "Component added", assetTag: assetTag };
    }

    // DELETE component
    resource function delete removeComponent/[string assetTag]/[string compName]() returns json {
        if !assetStore.hasKey(assetTag) {
            return { status: "error", message: "Asset not found", assetTag: assetTag };
        }
        Asset? maybeAsset = assetStore[assetTag];
        if maybeAsset is Asset {
            _ = maybeAsset.components.remove(compName);
        }
        return { status: "success", message: "Component removed", assetTag: assetTag };
    }

    // POST add schedule
    resource function post addSchedule/[string assetTag](@http:Payload Schedule sched) returns json {
        if !assetStore.hasKey(assetTag) {
            return { status: "error", message: "Asset not found", assetTag: assetTag };
        }
        assetStore[assetTag].schedules[sched.name] = sched;
        return { status: "success", message: "Schedule added", assetTag: assetTag };
    }

    // DELETE schedule
    resource function delete removeSchedule/[string assetTag]/[string schedName]() returns json {
        if !assetStore.hasKey(assetTag) {
            return { status: "error", message: "Asset not found", assetTag: assetTag };
        }
        Asset? maybeAsset = assetStore[assetTag];
        if maybeAsset is Asset {
            _ = maybeAsset.schedules.remove(schedName);
        }
        return { status: "success", message: "Schedule removed", assetTag: assetTag };
    }

    // POST add work order
    resource function post addWorkOrder/[string assetTag](@http:Payload WorkOrder wo) returns json {
        if !assetStore.hasKey(assetTag) {
            return { status: "error", message: "Asset not found", assetTag: assetTag };
        }
        assetStore[assetTag].workOrders[wo.description] = wo;
        return { status: "success", message: "WorkOrder added", assetTag: assetTag };
    }

    // DELETE work order
    resource function delete removeWorkOrder/[string assetTag]/[string woDesc]() returns json {
        if !assetStore.hasKey(assetTag) {
            return { status: "error", message: "Asset not found", assetTag: assetTag };
        }
        Asset? maybeAsset = assetStore[assetTag];
        if maybeAsset is Asset {
            _ = maybeAsset.workOrders.remove(woDesc);
        }
        return { status: "success", message: "WorkOrder removed", assetTag: assetTag };
    }
}
