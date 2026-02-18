class UserProfileModel {
  final String userId;
  final String name;
  final String? bio;
  final String? occupation;
  final bool isPro;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfileModel({
    required this.userId,
    required this.name,
    this.bio,
    this.occupation,
    this.isPro = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfileModel.empty(String userId) {
    final now = DateTime.now();
    return UserProfileModel(
      userId: userId,
      name: '',
      bio: null,
      occupation: null,
      isPro: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  UserProfileModel copyWith({
    String? name,
    String? bio,
    String? occupation,
    bool? isPro,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      userId: userId,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      occupation: occupation ?? this.occupation,
      isPro: isPro ?? this.isPro,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'bio': bio,
      'occupation': occupation,
      'isPro': isPro,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      userId: map['userId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      bio: map['bio'] as String?,
      occupation: map['occupation'] as String?,
      isPro: map['isPro'] as bool? ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
