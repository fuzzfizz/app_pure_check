class UserProfile {
  final String id;
  final String email;
  final String skinType;
  final List<String> skinConcerns;

  UserProfile({
    required this.id,
    required this.email,
    this.skinType = 'unknown',
    this.skinConcerns = const [],
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      skinType: json['skin_type'] ?? 'unknown',
      skinConcerns: List<String>.from(json['skin_concerns'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'skin_type': skinType,
      'skin_concerns': skinConcerns,
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? skinType,
    List<String>? skinConcerns,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      skinType: skinType ?? this.skinType,
      skinConcerns: skinConcerns ?? this.skinConcerns,
    );
  }
}
