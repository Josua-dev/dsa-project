public type Car record {
    string plate = "";
    string make = "";
    string model = "";
    int year = 0;
    float daily_price = 0.0;
    float mileage = 0.0;
    string status = "";
};

public type User record {
    string user_id = "";
    string name = "";
    string role = "";
};

public type CarRequest record {
    string plate = "";
};

public type CarFilter record {
    string filter_text = "";
    int year = 0;
};

public type CartRequest record {
    string customer_id = "";
    string plate = "";
    string start_date = "";
    string end_date = "";
};

public type ReservationRequest record {
    string customer_id = "";
};

public type CarResponse record {
    boolean success = false;
    string message = "";
    Car car = {};
};

public type CarListResponse record {
    Car[] cars = [];
};

public type UserResponse record {
    boolean success = false;
    string message = "";
};

public type CartResponse record {
    boolean success = false;
    string message = "";
};

public type ReservationResponse record {
    boolean success = false;
    string message = "";
    float total_price = 0.0;
    string reservation_id = "";
};