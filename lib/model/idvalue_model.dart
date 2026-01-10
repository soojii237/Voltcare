// To parse this JSON data, do
//
//     final idValue = idValueFromJson(jsonString);

import 'dart:convert';

IdValue idValueFromJson(String str) => IdValue.fromJson(json.decode(str));

String idValueToJson(IdValue data) => json.encode(data.toJson());

class IdValue {
    String? id;
    String? value;

    IdValue({
        this.id,
        this.value,
    });

    factory IdValue.fromJson(Map<String, dynamic> json) => IdValue(
        id: json["id"],
        value: json["value"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "value": value,
    };
}
