import 'package:app_core/app_core.dart';
import 'package:app_network/app_network.dart';

import '../entities/auth_login_method.dart';
import '../entities/auth_session.dart';
import '../entities/phone_otp_challenge.dart';

abstract class AuthRepository {
  Future<Result<AuthSession>> getCurrentSession();

  Future<Result<PhoneOtpChallenge>> requestPhoneOtp({
    required String phoneNumber,
    required PhoneOtpPurpose purpose,
  });

  Future<Result<AuthSession>> verifyPhoneOtp({
    required String phoneNumber,
    required String otpCode,
    required PhoneOtpPurpose purpose,
    String? challengeId,
  });

  Future<Result<AuthSession>> loginWithMethod(AuthLoginMethod method);

  Future<Result<void>> logout({bool revokeRemote = true});

  Future<Result<AuthTokens>> refreshTokens(String refreshToken);
}
