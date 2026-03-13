import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.role,
    required super.joinedAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final joined = json['joinedAt'] as String?;
    return UserProfileModel(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? 'Alex Morgan',
      email: json['email'] as String? ?? 'alex@example.com',
      role: json['role'] as String? ?? 'Product Lead',
      joinedAt: joined == null ? DateTime.now() : DateTime.parse(joined),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'role': role,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }
}
