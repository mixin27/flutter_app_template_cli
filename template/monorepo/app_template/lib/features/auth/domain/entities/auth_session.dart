import 'package:equatable/equatable.dart';

class AuthSession extends Equatable {
  const AuthSession._({
    required this.isAuthenticated,
    this.accessToken,
    this.refreshToken,
  });

  const AuthSession.authenticated({
    required String accessToken,
    required String refreshToken,
  }) : this._(
         isAuthenticated: true,
         accessToken: accessToken,
         refreshToken: refreshToken,
       );

  const AuthSession.unauthenticated() : this._(isAuthenticated: false);

  final bool isAuthenticated;
  final String? accessToken;
  final String? refreshToken;

  @override
  List<Object?> get props => [isAuthenticated, accessToken, refreshToken];
}
