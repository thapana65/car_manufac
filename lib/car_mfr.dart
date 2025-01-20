// To parse this JSON data, do
//
//     final carMfr = carMfrFromJson(jsonString);

import 'dart:convert';

CarMfr carMfrFromJson(String str) => CarMfr.fromJson(json.decode(str));

String carMfrToJson(CarMfr data) => json.encode(data.toJson());

class CarMfr {
    int? count;
    String? message;
    dynamic searchCriteria;
    List<Result>? results;

    CarMfr({
        this.count,
        this.message,
        this.searchCriteria,
        this.results,
    });

    factory CarMfr.fromJson(Map<String, dynamic> json) => CarMfr(
        count: json["Count"],
        message: json["Message"],
        searchCriteria: json["SearchCriteria"],
        results: json["Results"] == null ? [] : List<Result>.from(json["Results"]!.map((x) => Result.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "Count": count,
        "Message": message,
        "SearchCriteria": searchCriteria,
        "Results": results == null ? [] : List<dynamic>.from(results!.map((x) => x.toJson())),
    };
}

class Result {
    String? country;
    String? mfrCommonName;
    int? mfrId;
    String? mfrName;
    List<VehicleType>? vehicleTypes;

    Result({
        this.country,
        this.mfrCommonName,
        this.mfrId,
        this.mfrName,
        this.vehicleTypes,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        country: json["Country"],
        mfrCommonName: json["Mfr_CommonName"],
        mfrId: json["Mfr_ID"],
        mfrName: json["Mfr_Name"],
        vehicleTypes: json["VehicleTypes"] == null ? [] : List<VehicleType>.from(json["VehicleTypes"]!.map((x) => VehicleType.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "Country": country,
        "Mfr_CommonName": mfrCommonName,
        "Mfr_ID": mfrId,
        "Mfr_Name": mfrName,
        "VehicleTypes": vehicleTypes == null ? [] : List<dynamic>.from(vehicleTypes!.map((x) => x.toJson())),
    };
}

class VehicleType {
    bool? isPrimary;
    Name? name;

    VehicleType({
        this.isPrimary,
        this.name,
    });

    factory VehicleType.fromJson(Map<String, dynamic> json) => VehicleType(
        isPrimary: json["IsPrimary"],
        name: nameValues.map[json["Name"]]!,
    );

    Map<String, dynamic> toJson() => {
        "IsPrimary": isPrimary,
        "Name": nameValues.reverse[name],
    };
}

enum Name {
    BUS,
    INCOMPLETE_VEHICLE,
    LOW_SPEED_VEHICLE_LSV,
    MOTORCYCLE,
    MULTIPURPOSE_PASSENGER_VEHICLE_MPV,
    OFF_ROAD_VEHICLE,
    PASSENGER_CAR,
    TRAILER,
    TRUCK
}

final nameValues = EnumValues({
    "Bus": Name.BUS,
    "Incomplete Vehicle": Name.INCOMPLETE_VEHICLE,
    "Low Speed Vehicle (LSV)": Name.LOW_SPEED_VEHICLE_LSV,
    "Motorcycle": Name.MOTORCYCLE,
    "Multipurpose Passenger Vehicle (MPV)": Name.MULTIPURPOSE_PASSENGER_VEHICLE_MPV,
    "Off Road Vehicle": Name.OFF_ROAD_VEHICLE,
    "Passenger Car": Name.PASSENGER_CAR,
    "Trailer": Name.TRAILER,
    "Truck": Name.TRUCK
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
