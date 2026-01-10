// To parse this JSON data, do
//
//     final equipmentsModel = equepmentsModelFromJson(jsonString);

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

List<EquipmentsModel> equipmentsModelFromJson(String str) => List<EquipmentsModel>.from(json.decode(str).map((x) => EquipmentsModel.fromJson(x)));

String equipmentsModelToJson(List<EquipmentsModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EquipmentsModel {
    String? id;
    DateTime? createdAt;
    String? name;
    String? image;
    String? subtitle;
    List<String>? namefilter;
    int? status;

    EquipmentsModel({
        this.id,
        this.createdAt,
        this.name,
        this.image,
        this.subtitle,
        this.namefilter,
        this.status,
    });

    factory EquipmentsModel.fromJson(Map<String, dynamic> json) => EquipmentsModel(
        id: json["id"],
        createdAt: json["createdAt"] is Timestamp
    ? (json["createdAt"] as Timestamp).toDate()
    : null,
        name: json["name"],
        image: json["image"],
        subtitle: json["subtitle"],
        namefilter: json["namefilter"] == null ? [] : List<String>.from(json["namefilter"]!.map((x) => x)),
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "createdAt": createdAt,
        "name": name,
        "image": image,
        "subtitle": subtitle,
        "namefilter": namefilter == null ? [] : List<dynamic>.from(namefilter!.map((x) => x)),
        "status": status,
    };
}
