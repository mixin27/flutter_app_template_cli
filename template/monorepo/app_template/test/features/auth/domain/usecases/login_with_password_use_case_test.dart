import 'package:app_core/app_core.dart';
import 'package:app_network/app_network.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:__APP_NAME__/features/auth/domain/entities/auth_login_method.dart';
import 'package:__APP_NAME__/features/auth/domain/entities/auth_session.dart';
import 'package:__APP_NAME__/features/auth/domain/entities/phone_otp_challenge.dart';
import 'package:__APP_NAME__/features/auth/domain/repositories/auth_repository.dart';
import 'package:__APP_NAME__/features/auth/domain/usecases/login_with_password_use_case.dart';

void main() {
  test('maps identifier/password into password auth method', () async {
    final repository = _FakeAuthRepository();
    final useCase = LoginWithPasswordUseCase(repository);

    final result = await useCase(
      const LoginWithPasswordParams(
        identifier: 'hello@example.com',
        password: 'secret',
      ),
    );

    expect(result.isSuccess, isTrue);
    expect(repository.receivedMethod?.type, equals(AuthMethodType.password));
    expect(
      repository.receivedMethod?.payload['identifier'],
      equals('hello@example.com'),
    );
  });
}

class _FakeAuthRepository implements AuthRepository {
  AuthLoginMethod? receivedMethod;

  @override
  Future<Result<AuthSession>> loginWithMethod(AuthLoginMethod method) async {
    receivedMethod = method;
    return Result.success(
      const AuthSession.authenticated(
        accessToken: 'access',
        refreshToken: 'refresh',
      ),
    );
  }

  @override
  Future<Result<AuthSession>> getCurrentSession() async {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> logout({bool revokeRemote = true}) async {
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
