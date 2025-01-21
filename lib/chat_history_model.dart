// To parse this JSON data, do
//
//     final chatHistory = chatHistoryFromJson(jsonString);

import 'dart:convert';

List<ChatHistory> chatHistoryFromJson(String str) => List<ChatHistory>.from(
    json.decode(str).map((x) => ChatHistory.fromJson(x)));

String chatHistoryToJson(List<ChatHistory> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ChatHistory {
  String? senderType;
  String? senderId;
  String? messageType;
  String? message;
  DateTime? timestamp;
  String? id;

  ChatHistory({
    this.senderType,
    this.senderId,
    this.messageType,
    this.message,
    this.timestamp,
    this.id,
  });

  factory ChatHistory.fromJson(Map<String, dynamic> json) => ChatHistory(
        senderType: json["senderType"],
        senderId: json["senderId"],
        messageType: json["messageType"],
        message: json["message"],
        timestamp: json["timestamp"] == null
            ? null
            : DateTime.parse(json["timestamp"]),
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "senderType": senderType,
        "senderId": senderId,
        "messageType": messageType,
        "message": message,
        "timestamp": timestamp?.toIso8601String(),
        "_id": id,
      };
}
