import 'package:equatable/equatable.dart';

import '../../domain/entities/auth_session.dart';
import '../../domain/entities/phone_otp_challenge.dart';

enum AuthStatus {
  unknown,
  checking,
  unauthenticated,
  otpRequested,
  authenticating,
  authenticated,
  loggingOut,
  failure,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.session,
    this.otpChallenge,
    this.errorMessage,
  });

  final AuthStatus status;
  final AuthSession? session;
  final PhoneOtpChallenge? otpChallenge;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    AuthSession? session,
    bool clearSession = false,
    PhoneOtpChallenge? otpChallenge,
    bool clearOtpChallenge = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: clearSession ? null : (session ?? this.session),
      otpChallenge: clearOtpChallenge
          ? null
          : (otpChallenge ?? this.otpChallenge),
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, session, otpChallenge, errorMessage];
}
