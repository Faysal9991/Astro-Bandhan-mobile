class Astrologer {
  final String id;
  final String name;
  final int experience;
  final List<String> specialities;
  final String avatar;
  final double pricePerCallMinute;

  Astrologer({
    required this.id,
    required this.name,
    required this.experience,
    required this.specialities,
    required this.avatar,
    required this.pricePerCallMinute,
  });

  // Parse data from JSON
  factory Astrologer.fromJson(Map<String, dynamic> json) {
    return Astrologer(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      experience: json['experience'] ?? 0,
      specialities: List<String>.from(json['specialities'] ?? []),
      avatar: json['avatar'] ?? '',
      pricePerCallMinute: json['pricePerCallMinute']?.toDouble() ?? 0.0,
    );
  }
}
