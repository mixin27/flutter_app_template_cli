import 'package:__APP_NAME__/features/auth/domain/entities/auth_login_method.dart';
import 'package:__APP_NAME__/features/auth/domain/entities/auth_session.dart';
import 'package:__APP_NAME__/features/auth/domain/entities/phone_otp_challenge.dart';
import 'package:__APP_NAME__/features/auth/domain/repositories/auth_repository.dart';
import 'package:__APP_NAME__/features/auth/domain/usecases/logout_use_case.dart';
import 'package:app_core/app_core.dart';
import 'package:app_network/app_network.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('passes revokeRemote flag to repository', () async {
    final repository = _FakeAuthRepository();
    final useCase = LogoutUseCase(repository);

    final result = await useCase(const LogoutParams(revokeRemote: false));

    expect(result.isSuccess, isTrue);
    expect(repository.receivedRevokeRemote, isFalse);
  });
}

class _FakeAuthRepository implements AuthRepository {
  bool? receivedRevokeRemote;

  @override
  Future<Result<void>> logout({bool revokeRemote = true}) async {
    receivedRevokeRemote = revokeRemote;
    return Result.success(null);
  }

  @override
  Future<Result<AuthSession>> getCurrentSession() async {
    throw UnimplementedError();
  }

  @override
  Future<Result<AuthSession>> loginWithMethod(AuthLoginMethod method) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<AuthTokens>> refreshTokens(String refreshToken) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<PhoneOtpChallenge>> requestPhoneOtp({
    required String phoneNumber,
    required PhoneOtpPurpose purpose,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<AuthSession>> verifyPhoneOtp({
    required String phoneNumber,
    required String otpCode,
    required PhoneOtpPurpose purpose,
    String? challengeId,
  }) async {
    throw UnimplementedError();
  }
}
