import ballerina/grpc;
import ballerina/protobuf;

public const string CAR_RENTAL_DESC = "0A1670726F746F2F6361725F72656E74616C2E70726F746F120A6361725F72656E74616C22AC010A0343617212140A05706C6174651801200128095205706C61746512120A046D616B6518022001280952046D616B6512140A056D6F64656C18032001280952056D6F64656C12120A0479656172180420012805520479656172121F0A0B6461696C795F7072696365180520012801520A6461696C79507269636512180A076D696C6561676518062001280152076D696C6561676512160A06737461747573180720012809520673746174757322470A045573657212170A07757365725F6964180120012809520675736572496412120A046E616D6518022001280952046E616D6512120A04726F6C651803200128095204726F6C6522220A0A4361725265717565737412140A05706C6174651801200128095205706C61746522400A0943617246696C746572121F0A0B66696C7465725F74657874180120012809520A66696C7465725465787412120A0479656172180220012805520479656172227E0A0B4361727452657175657374121F0A0B637573746F6D65725F6964180120012809520A637573746F6D6572496412140A05706C6174651802200128095205706C617465121D0A0A73746172745F64617465180320012809520973746172744461746512190A08656E645F646174651804200128095207656E644461746522350A125265736572766174696F6E52657175657374121F0A0B637573746F6D65725F6964180120012809520A637573746F6D6572496422640A0B436172526573706F6E736512180A077375636365737318012001280852077375636365737312180A076D65737361676518022001280952076D65737361676512210A0363617218032001280B320F2E6361725F72656E74616C2E436172520363617222360A0F4361724C697374526573706F6E736512230A046361727318012003280B320F2E6361725F72656E74616C2E43617252046361727322420A0C55736572526573706F6E736512180A077375636365737318012001280852077375636365737312180A076D65737361676518022001280952076D65737361676522420A0C43617274526573706F6E736512180A077375636365737318012001280852077375636365737312180A076D65737361676518022001280952076D6573736167652291010A135265736572766174696F6E526573706F6E736512180A077375636365737318012001280852077375636365737312180A076D65737361676518022001280952076D657373616765121F0A0B746F74616C5F7072696365180320012801520A746F74616C507269636512250A0E7265736572766174696F6E5F6964180420012809520D7265736572766174696F6E4964328E040A1043617252656E74616C5365727669636512320A06416464436172120F2E6361725F72656E74616C2E4361721A172E6361725F72656E74616C2E436172526573706F6E7365123B0A0B437265617465557365727312102E6361725F72656E74616C2E557365721A182E6361725F72656E74616C2E55736572526573706F6E7365280112350A09557064617465436172120F2E6361725F72656E74616C2E4361721A172E6361725F72656E74616C2E436172526573706F6E736512400A0952656D6F766543617212162E6361725F72656E74616C2E436172526571756573741A1B2E6361725F72656E74616C2E4361724C697374526573706F6E7365123D0A114C697374417661696C61626C654361727312152E6361725F72656E74616C2E43617246696C7465721A0F2E6361725F72656E74616C2E4361723001123C0A0953656172636843617212162E6361725F72656E74616C2E436172526571756573741A172E6361725F72656E74616C2E436172526573706F6E7365123E0A09416464546F4361727412172E6361725F72656E74616C2E43617274526571756573741A182E6361725F72656E74616C2E43617274526573706F6E736512530A10506C6163655265736572766174696F6E121E2E6361725F72656E74616C2E5265736572766174696F6E526571756573741A1F2E6361725F72656E74616C2E5265736572766174696F6E526573706F6E7365620670726F746F33";

public isolated client class CarRentalServiceClient {
    *grpc:AbstractClientEndpoint;

    private final grpc:Client grpcClient;

    public isolated function init(string url, *grpc:ClientConfiguration config) returns grpc:Error? {
        self.grpcClient = check new (url, config);
        check self.grpcClient.initStub(self, CAR_RENTAL_DESC);
    }

    isolated remote function AddCar(Car|ContextCar req) returns CarResponse|grpc:Error {
        map<string|string[]> headers = {};
        Car message;
        if req is ContextCar {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/AddCar", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <CarResponse>result;
    }

    isolated remote function AddCarContext(Car|ContextCar req) returns ContextCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        Car message;
        if req is ContextCar {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/AddCar", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <CarResponse>result, headers: respHeaders};
    }

    isolated remote function UpdateCar(Car|ContextCar req) returns CarResponse|grpc:Error {
        map<string|string[]> headers = {};
        Car message;
        if req is ContextCar {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/UpdateCar", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <CarResponse>result;
    }

    isolated remote function UpdateCarContext(Car|ContextCar req) returns ContextCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        Car message;
        if req is ContextCar {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/UpdateCar", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <CarResponse>result, headers: respHeaders};
    }

    isolated remote function RemoveCar(CarRequest|ContextCarRequest req) returns CarListResponse|grpc:Error {
        map<string|string[]> headers = {};
        CarRequest message;
        if req is ContextCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/RemoveCar", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <CarListResponse>result;
    }

    isolated remote function RemoveCarContext(CarRequest|ContextCarRequest req) returns ContextCarListResponse|grpc:Error {
        map<string|string[]> headers = {};
        CarRequest message;
        if req is ContextCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/RemoveCar", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <CarListResponse>result, headers: respHeaders};
    }

    isolated remote function SearchCar(CarRequest|ContextCarRequest req) returns CarResponse|grpc:Error {
        map<string|string[]> headers = {};
        CarRequest message;
        if req is ContextCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/SearchCar", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <CarResponse>result;
    }

    isolated remote function SearchCarContext(CarRequest|ContextCarRequest req) returns ContextCarResponse|grpc:Error {
        map<string|string[]> headers = {};
        CarRequest message;
        if req is ContextCarRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/SearchCar", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <CarResponse>result, headers: respHeaders};
    }

    isolated remote function AddToCart(CartRequest|ContextCartRequest req) returns CartResponse|grpc:Error {
        map<string|string[]> headers = {};
        CartRequest message;
        if req is ContextCartRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/AddToCart", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <CartResponse>result;
    }

    isolated remote function AddToCartContext(CartRequest|ContextCartRequest req) returns ContextCartResponse|grpc:Error {
        map<string|string[]> headers = {};
        CartRequest message;
        if req is ContextCartRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/AddToCart", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <CartResponse>result, headers: respHeaders};
    }

    isolated remote function PlaceReservation(ReservationRequest|ContextReservationRequest req) returns ReservationResponse|grpc:Error {
        map<string|string[]> headers = {};
        ReservationRequest message;
        if req is ContextReservationRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/PlaceReservation", message, headers);
        [anydata, map<string|string[]>] [result, _] = payload;
        return <ReservationResponse>result;
    }

    isolated remote function PlaceReservationContext(ReservationRequest|ContextReservationRequest req) returns ContextReservationResponse|grpc:Error {
        map<string|string[]> headers = {};
        ReservationRequest message;
        if req is ContextReservationRequest {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeSimpleRPC("car_rental.CarRentalService/PlaceReservation", message, headers);
        [anydata, map<string|string[]>] [result, respHeaders] = payload;
        return {content: <ReservationResponse>result, headers: respHeaders};
    }

    isolated remote function CreateUsers() returns CreateUsersStreamingClient|grpc:Error {
        grpc:StreamingClient sClient = check self.grpcClient->executeClientStreaming("car_rental.CarRentalService/CreateUsers");
        return new CreateUsersStreamingClient(sClient);
    }

    isolated remote function ListAvailableCars(CarFilter|ContextCarFilter req) returns stream<Car, grpc:Error?>|grpc:Error {
        map<string|string[]> headers = {};
        CarFilter message;
        if req is ContextCarFilter {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("car_rental.CarRentalService/ListAvailableCars", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, _] = payload;
        CarStream outputStream = new CarStream(result);
        return new stream<Car, grpc:Error?>(outputStream);
    }

    isolated remote function ListAvailableCarsContext(CarFilter|ContextCarFilter req) returns ContextCarStream|grpc:Error {
        map<string|string[]> headers = {};
        CarFilter message;
        if req is ContextCarFilter {
            message = req.content;
            headers = req.headers;
        } else {
            message = req;
        }
        var payload = check self.grpcClient->executeServerStreaming("car_rental.CarRentalService/ListAvailableCars", message, headers);
        [stream<anydata, grpc:Error?>, map<string|string[]>] [result, respHeaders] = payload;
        CarStream outputStream = new CarStream(result);
        return {content: new stream<Car, grpc:Error?>(outputStream), headers: respHeaders};
    }
}

public isolated client class CreateUsersStreamingClient {
    private final grpc:StreamingClient sClient;

    isolated function init(grpc:StreamingClient sClient) {
        self.sClient = sClient;
    }

    isolated remote function sendUser(User message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function sendContextUser(ContextUser message) returns grpc:Error? {
        return self.sClient->send(message);
    }

    isolated remote function receiveUserResponse() returns UserResponse|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, _] = response;
            return <UserResponse>payload;
        }
    }

    isolated remote function receiveContextUserResponse() returns ContextUserResponse|grpc:Error? {
        var response = check self.sClient->receive();
        if response is () {
            return response;
        } else {
            [anydata, map<string|string[]>] [payload, headers] = response;
            return {content: <UserResponse>payload, headers: headers};
        }
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.sClient->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.sClient->complete();
    }
}

public class CarStream {
    private stream<anydata, grpc:Error?> anydataStream;

    public isolated function init(stream<anydata, grpc:Error?> anydataStream) {
        self.anydataStream = anydataStream;
    }

    public isolated function next() returns record {|Car value;|}|grpc:Error? {
        var streamValue = self.anydataStream.next();
        if streamValue is () {
            return streamValue;
        } else if streamValue is grpc:Error {
            return streamValue;
        } else {
            record {|Car value;|} nextRecord = {value: <Car>streamValue.value};
            return nextRecord;
        }
    }

    public isolated function close() returns grpc:Error? {
        return self.anydataStream.close();
    }
}

public isolated client class CarRentalServiceCarListResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendCarListResponse(CarListResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextCarListResponse(ContextCarListResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalServiceReservationResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendReservationResponse(ReservationResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextReservationResponse(ContextReservationResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalServiceCarResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendCarResponse(CarResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextCarResponse(ContextCarResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalServiceCarCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendCar(Car response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextCar(ContextCar response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalServiceCartResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendCartResponse(CartResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextCartResponse(ContextCartResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public isolated client class CarRentalServiceUserResponseCaller {
    private final grpc:Caller caller;

    public isolated function init(grpc:Caller caller) {
        self.caller = caller;
    }

    public isolated function getId() returns int {
        return self.caller.getId();
    }

    isolated remote function sendUserResponse(UserResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendContextUserResponse(ContextUserResponse response) returns grpc:Error? {
        return self.caller->send(response);
    }

    isolated remote function sendError(grpc:Error response) returns grpc:Error? {
        return self.caller->sendError(response);
    }

    isolated remote function complete() returns grpc:Error? {
        return self.caller->complete();
    }

    public isolated function isCancelled() returns boolean {
        return self.caller.isCancelled();
    }
}

public type ContextUserStream record {|
    stream<User, error?> content;
    map<string|string[]> headers;
|};

public type ContextCarStream record {|
    stream<Car, error?> content;
    map<string|string[]> headers;
|};

public type ContextUserResponse record {|
    UserResponse content;
    map<string|string[]> headers;
|};

public type ContextReservationResponse record {|
    ReservationResponse content;
    map<string|string[]> headers;
|};

public type ContextUser record {|
    User content;
    map<string|string[]> headers;
|};

public type ContextCarFilter record {|
    CarFilter content;
    map<string|string[]> headers;
|};

public type ContextCar record {|
    Car content;
    map<string|string[]> headers;
|};

public type ContextReservationRequest record {|
    ReservationRequest content;
    map<string|string[]> headers;
|};

public type ContextCarListResponse record {|
    CarListResponse content;
    map<string|string[]> headers;
|};

public type ContextCartRequest record {|
    CartRequest content;
    map<string|string[]> headers;
|};

public type ContextCarResponse record {|
    CarResponse content;
    map<string|string[]> headers;
|};

public type ContextCarRequest record {|
    CarRequest content;
    map<string|string[]> headers;
|};

public type ContextCartResponse record {|
    CartResponse content;
    map<string|string[]> headers;
|};

@protobuf:Descriptor {value: CAR_RENTAL_DESC}
public type UserResponse record {|
    boolean success = false;
    string message = "";
|};

@protobuf:Descriptor {value: CAR_RENTAL_DESC}
public type ReservationResponse record {|
    boolean success = false;
    string message = "";
    float total_price = 0.0;
    string reservation_id = "";
|};

@protobuf:Descriptor {value: CAR_RENTAL_DESC}
public type User record {|
    string user_id = "";
    string name = "";
    string role = "";
|};

@protobuf:Descriptor {value: CAR_RENTAL_DESC}
public type CarFilter record {|
    string filter_text = "";
    int year = 0;
|};

@protobuf:Descriptor {value: CAR_RENTAL_DESC}
public type Car record {|
    string plate = "";
    string make = "";
    string model = "";
    int year = 0;
    float daily_price = 0.0;
    float mileage = 0.0;
    string status = "";
|};

@protobuf:Descriptor {value: CAR_RENTAL_DESC}
public type ReservationRequest record {|
    string customer_id = "";
|};

@protobuf:Descriptor {value: CAR_RENTAL_DESC}
public type CartRequest record {|
    string customer_id = "";
    string plate = "";
    string start_date = "";
    string end_date = "";
|};

@protobuf:Descriptor {value: CAR_RENTAL_DESC}
public type CarListResponse record {|
    Car[] cars = [];
|};

@protobuf:Descriptor {value: CAR_RENTAL_DESC}
public type CarResponse record {|
    boolean success = false;
    string message = "";
    Car car = {};
|};

@protobuf:Descriptor {value: CAR_RENTAL_DESC}
public type CarRequest record {|
    string plate = "";
|};

@protobuf:Descriptor {value: CAR_RENTAL_DESC}
public type CartResponse record {|
    boolean success = false;
    string message = "";
|};
