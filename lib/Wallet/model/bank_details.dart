class BankDetails {
  String accountNumber;
  String accountHolderName;
  String ifscCode;

  BankDetails({
    required this.accountNumber,
    required this.accountHolderName,
    required this.ifscCode,
  });

  // From JSON
  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      accountNumber: json['accountNumber'] as String,
      accountHolderName: json['accountHolderName'] as String,
      ifscCode: json['ifscCode'] as String,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'accountNumber': accountNumber,
      'accountHolderName': accountHolderName,
      'ifscCode': ifscCode,
    };
  }
}
