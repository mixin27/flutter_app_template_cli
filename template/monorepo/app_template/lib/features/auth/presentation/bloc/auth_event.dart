import 'package:equatable/equatable.dart';

import '../../domain/entities/auth_login_method.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/phone_otp_challenge.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AppStarted extends AuthEvent {
  const AppStarted();
}

final class LoggedIn extends AuthEvent {
  const LoggedIn(this.session);

  final AuthSession session;

  @override
  List<Object?> get props => [session];
}

final class LoggedOut extends AuthEvent {
  const LoggedOut({this.revokeRemote = true});

  final bool revokeRemote;

  @override
  List<Object?> get props => [revokeRemote];
}

final class SessionExpired extends AuthEvent {
  const SessionExpired();
}

final class PhoneOtpRequested extends AuthEvent {
  const PhoneOtpRequested({required this.phoneNumber, required this.purpose});

  final String phoneNumber;
  final PhoneOtpPurpose purpose;

  @override
  List<Object?> get props => [phoneNumber, purpose];
}

final class PhoneOtpVerified extends AuthEvent {
  const PhoneOtpVerified({
    required this.phoneNumber,
    required this.otpCode,
    required this.purpose,
    this.challengeId,
  });

  final String phoneNumber;
  final String otpCode;
  final PhoneOtpPurpose purpose;
  final String? challengeId;

  @override
  List<Object?> get props => [phoneNumber, otpCode, purpose, challengeId];
}

final class EmailPasswordLoginRequested extends AuthEvent {
  const EmailPasswordLoginRequested({
    required this.identifier,
    required this.password,
  });

  final String identifier;
  final String password;

  @override
  List<Object?> get props => [identifier, password];
}

final class MethodLoginRequested extends AuthEvent {
  const MethodLoginRequested(this.method);

  final AuthLoginMethod method;

  @override
  List<Object?> get props => [method];
}
