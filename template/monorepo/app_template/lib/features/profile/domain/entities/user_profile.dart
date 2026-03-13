import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.joinedAt,
  });

  final String id;
  final String fullName;
  final String email;
  final String role;
  final DateTime joinedAt;

  @override
  List<Object?> get props => [id, fullName, email, role, joinedAt];
}
