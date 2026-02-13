import ballerina/http;

// Define WorkOrder type
type WorkOrder record {|
    string workOrderId;
    string description;
    string status; // OPEN, IN_PROGRESS, CLOSED
    map<string> tasks;
|};

// Define Asset type
type Asset record {|
    string assetTag;
    string name;
    string faculty;
    string department;
    string status; // ACTIVE, UNDER_REPAIR, DISPOSED
    string acquiredDate;
    map<string> components;
    map<string> schedules;
    map<WorkOrder> workOrders;
|};

// In-memory database
map<Asset> assets = {};

// Service
service /assets on new http:Listener(8080) {

    // CREATE
    resource function post .(Asset asset) returns json|error {
        if assets.hasKey(asset.assetTag) {
            return error("Asset already exists: " + asset.assetTag);
        }
        assets[asset.assetTag] = asset;
        return { message: "Asset added", assetTag: asset.assetTag };
    }

    // GET by assetTag
    resource function get [string assetTag]() returns Asset|error {
        Asset? maybe = assets[assetTag];
        if maybe is Asset {
            return maybe;
        }
        return error("Asset not found: " + assetTag);
    }

    // GET all assets
    resource function get .() returns Asset[] {
        return assets.values();
    }

    // UPDATE
    resource function put .(Asset asset) returns json|error {
        Asset? maybe = assets[asset.assetTag];
        if maybe is Asset {
            assets[asset.assetTag] = asset;
            return { message: "Asset updated", assetTag: asset.assetTag };
        }
        return error("Asset not found: " + asset.assetTag);
    }

    // DELETE
    resource function delete [string assetTag]() returns json|error {
        if assets.remove(assetTag) is () {
            return { message: "Asset removed", assetTag: assetTag };
        }
        return error("Asset not found: " + assetTag);
    }

    // VIEW BY FACULTY
    resource function get faculty/[string facultyName]() returns Asset[] {
        Asset[] res = [];
        foreach var a in assets.values() {
            if a.faculty == facultyName {
                res.push(a);
            }
        }
        return res;
    }

}
