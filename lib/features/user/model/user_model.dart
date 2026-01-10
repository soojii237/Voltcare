import 'dart:convert';

List<UserModel> userModelFromJson(String str) =>
    List<UserModel>.from(json.decode(str).map((x) => UserModel.fromJson(x)));

String userModelToJson(List<UserModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserModel {
  String? address;
  String? createdAt; // ---> formatted date string
  String? email;
  String? name;
  List<String>? namefilter;
  String? role;
  String? phone;
  int? status;
  String? uid;

  UserModel({
    this.address,
    this.createdAt,
    this.email,
    this.name,
    this.namefilter,
    this.role,
    this.phone,
    this.status,
    this.uid,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {

    // Handle Timestamp or String  
    String? formattedDate;
    if (json["createdAt"] != null) {
      if (json["createdAt"] is Map && json["createdAt"]["_seconds"] != null) {
        // Firestore timestamp when converting from API/REST
        var seconds = json["createdAt"]["_seconds"];
        DateTime date =
            DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
        formattedDate = _formatDate(date);
      } else if (json["createdAt"] is int) {
        // If timestamp comes as milliseconds
        DateTime date =
            DateTime.fromMillisecondsSinceEpoch(json["createdAt"]);
        formattedDate = _formatDate(date);
      } else if (json["createdAt"] is String) {
        // Already string — parse if possible
        try {
          DateTime date = DateTime.parse(json["createdAt"]);
          formattedDate = _formatDate(date);
        } catch (e) {
          formattedDate = json["createdAt"]; // fallback
        }
      }
    }

    return UserModel(
      address: json["address"],
      createdAt: formattedDate,
      email: json["email"],
      name: json["name"],
      namefilter: json["namefilter"] == null
          ? []
          : List<String>.from(json["namefilter"].map((x) => x)),
      role: json["role"],
      phone: json["phone"],
      status: json["status"],
      uid: json["uid"],
    );
  }

  Map<String, dynamic> toJson() => {
        "address": address,
        "createdAt": createdAt,
        "email": email,
        "name": name,
        "namefilter":
            namefilter == null ? [] : List<dynamic>.from(namefilter!.map((x) => x)),
        "role": role,
        "phone": phone,
        "status": status,
        "uid": uid,
      };

  /// Convert DateTime → "dd-mm-yyyy"
  static String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-"
           "${date.month.toString().padLeft(2, '0')}-"
           "${date.year}";
  }
}
