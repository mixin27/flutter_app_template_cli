import '../../domain/entities/auth_session.dart';
import 'user_model.dart';

class AuthSessionModel {
  AuthSessionModel({required this.token, required this.user});

  final String token;
  final UserModel user;

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      token: json['token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  AuthSession toEntity() => AuthSession(token: token, user: user.toEntity());
}
