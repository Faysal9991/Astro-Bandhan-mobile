// To parse this JSON data, do
//
//     final userInfoModel = userInfoModelFromJson(jsonString);

import 'dart:convert';

UserInfoModel userInfoModelFromJson(String str) =>
    UserInfoModel.fromJson(json.decode(str));

String userInfoModelToJson(UserInfoModel data) => json.encode(data.toJson());

class UserInfoModel {
  String? id;
  String? name;
  int? experience;
  List<String>? specialities;
  List<String>? languages;
  int? rating;
  int? totalRatingsCount;
  int? pricePerCallMinute;
  int? pricePerVideoCallMinute;
  int? pricePerChatMinute;
  Available? available;
  bool? isVerified;
  bool? isFeatured;
  String? password;
  String? gender;
  String? phone;
  int? walletBalance;
  int? chatCommission;
  int? callCommission;
  int? videoCallCommission;
  String? avatar;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? selectedLanguageId;
  int? v;
  String? refreshToken;
  bool? isOffline;

  UserInfoModel({
    this.id,
    this.name,
    this.experience,
    this.specialities,
    this.languages,
    this.rating,
    this.totalRatingsCount,
    this.pricePerCallMinute,
    this.pricePerVideoCallMinute,
    this.pricePerChatMinute,
    this.available,
    this.isVerified,
    this.isFeatured,
    this.password,
    this.gender,
    this.phone,
    this.walletBalance,
    this.chatCommission,
    this.callCommission,
    this.videoCallCommission,
    this.avatar,
    this.createdAt,
    this.updatedAt,
    this.selectedLanguageId,
    this.v,
    this.refreshToken,
    this.isOffline,
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) => UserInfoModel(
        id: json["_id"],
        name: json["name"],
        experience: json["experience"],
        specialities: json["specialities"] == null
            ? []
            : List<String>.from(json["specialities"]!.map((x) => x)),
        languages: json["languages"] == null
            ? []
            : List<String>.from(json["languages"]!.map((x) => x)),
        rating: json["rating"],
        totalRatingsCount: json["totalRatingsCount"],
        pricePerCallMinute: json["pricePerCallMinute"],
        pricePerVideoCallMinute: json["pricePerVideoCallMinute"],
        pricePerChatMinute: json["pricePerChatMinute"],
        available: json["available"] == null
            ? null
            : Available.fromJson(json["available"]),
        isVerified: json["isVerified"],
        isFeatured: json["isFeatured"],
        password: json["password"],
        gender: json["gender"],
        phone: json["phone"],
        walletBalance: json["walletBalance"],
        chatCommission: json["chatCommission"],
        callCommission: json["callCommission"],
        videoCallCommission: json["videoCallCommission"],
        avatar: json["avatar"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        selectedLanguageId: json["selected_language_id"],
        v: json["__v"],
        refreshToken: json["refreshToken"],
        isOffline: json["isOffline"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "experience": experience,
        "specialities": specialities == null
            ? []
            : List<dynamic>.from(specialities!.map((x) => x)),
        "languages": languages == null
            ? []
            : List<dynamic>.from(languages!.map((x) => x)),
        "rating": rating,
        "totalRatingsCount": totalRatingsCount,
        "pricePerCallMinute": pricePerCallMinute,
        "pricePerVideoCallMinute": pricePerVideoCallMinute,
        "pricePerChatMinute": pricePerChatMinute,
        "available": available?.toJson(),
        "isVerified": isVerified,
        "isFeatured": isFeatured,
        "password": password,
        "gender": gender,
        "phone": phone,
        "walletBalance": walletBalance,
        "chatCommission": chatCommission,
        "callCommission": callCommission,
        "videoCallCommission": videoCallCommission,
        "avatar": avatar,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "selected_language_id": selectedLanguageId,
        "__v": v,
        "refreshToken": refreshToken,
        "isOffline": isOffline,
      };
}

class Available {
  bool? isAvailable;
  bool? isCallAvailable;
  bool? isChatAvailable;
  bool? isVideoCallAvailable;
  String? id;

  Available({
    this.isAvailable,
    this.isCallAvailable,
    this.isChatAvailable,
    this.isVideoCallAvailable,
    this.id,
  });

  factory Available.fromJson(Map<String, dynamic> json) => Available(
        isAvailable: json["isAvailable"],
        isCallAvailable: json["isCallAvailable"],
        isChatAvailable: json["isChatAvailable"],
        isVideoCallAvailable: json["isVideoCallAvailable"],
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "isAvailable": isAvailable,
        "isCallAvailable": isCallAvailable,
        "isChatAvailable": isChatAvailable,
        "isVideoCallAvailable": isVideoCallAvailable,
        "_id": id,
      };
}
