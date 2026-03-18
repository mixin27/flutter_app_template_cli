import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  const Profile({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final DateTime updatedAt;

  Profile copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, email, avatarUrl, updatedAt];
}
