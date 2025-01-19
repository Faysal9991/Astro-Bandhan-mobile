// To parse this JSON data, do
//
//     final waletHistory = waletHistoryFromJson(jsonString);

import 'dart:convert';

List<WaletHistory> waletHistoryFromJson(String str) => List<WaletHistory>.from(
    json.decode(str).map((x) => WaletHistory.fromJson(x)));

String waletHistoryToJson(List<WaletHistory> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class WaletHistory {
  String? id;
  dynamic userId;
  AstrologerId? astrologerId;
  int? amount;
  String? transactionId;
  TransactionType? transactionType;
  dynamic debitType;
  CreditType? creditType;
  String? serviceReferenceId;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  WaletHistory({
    this.id,
    this.userId,
    this.astrologerId,
    this.amount,
    this.transactionId,
    this.transactionType,
    this.debitType,
    this.creditType,
    this.serviceReferenceId,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory WaletHistory.fromJson(Map<String, dynamic> json) => WaletHistory(
        id: json["_id"],
        userId: json["user_id"],
        astrologerId: astrologerIdValues.map[json["astrologer_id"]]!,
        amount: json["amount"],
        transactionId: json["transaction_id"],
        transactionType: transactionTypeValues.map[json["transaction_type"]]!,
        debitType: json["debit_type"],
        creditType: creditTypeValues.map[json["credit_type"]]!,
        serviceReferenceId: json["service_reference_id"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "user_id": userId,
        "astrologer_id": astrologerIdValues.reverse[astrologerId],
        "amount": amount,
        "transaction_id": transactionId,
        "transaction_type": transactionTypeValues.reverse[transactionType],
        "debit_type": debitType,
        "credit_type": creditTypeValues.reverse[creditType],
        "service_reference_id": serviceReferenceId,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}

enum AstrologerId { THE_676_C5103_DF120965_C2_F1743_D }

final astrologerIdValues = EnumValues({
  "676c5103df120965c2f1743d": AstrologerId.THE_676_C5103_DF120965_C2_F1743_D
});

enum CreditType { CALL, CHAT }

final creditTypeValues =
    EnumValues({"call": CreditType.CALL, "chat": CreditType.CHAT});

enum TransactionType { CREDIT, DEBIT }

final transactionTypeValues = EnumValues({
  "credit": TransactionType.CREDIT,
  "debit": TransactionType.DEBIT,
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
