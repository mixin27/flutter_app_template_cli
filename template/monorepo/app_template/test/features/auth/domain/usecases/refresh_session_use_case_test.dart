import 'package:__APP_NAME__/features/auth/domain/entities/auth_login_method.dart';
import 'package:__APP_NAME__/features/auth/domain/entities/auth_session.dart';
import 'package:__APP_NAME__/features/auth/domain/entities/phone_otp_challenge.dart';
import 'package:__APP_NAME__/features/auth/domain/repositories/auth_repository.dart';
import 'package:__APP_NAME__/features/auth/domain/usecases/refresh_session_use_case.dart';
import 'package:app_core/app_core.dart';
import 'package:app_network/app_network.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('returns repository result with provided refresh token', () async {
    final repository = _FakeAuthRepository();
    final refreshUseCase = RefreshSessionUseCase(repository);

    final result = await refreshUseCase(
      const RefreshSessionParams('refresh-token'),
    );

    expect(result.isSuccess, isTrue);
    expect(repository.receivedRefreshToken, equals('refresh-token'));
    expect(result.dataOrNull?.accessToken, equals('access-token'));
  });

  test('propagates repository failure', () async {
    final repository = _FakeAuthRepository(
      result: Result<AuthTokens>.failure(const NetworkFailure('offline')),
    );
    final refreshUseCase = RefreshSessionUseCase(repository);

    final result = await refreshUseCase(
      const RefreshSessionParams('refresh-token'),
    );

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, equals(const NetworkFailure('offline')));
  });
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({Result<AuthTokens>? result})
    : _result =
          result ??
          Result<AuthTokens>.success(
            const AuthTokens(
              accessToken: 'access-token',
              refreshToken: 'refresh-token',
            ),
          );

  final Result<AuthTokens> _result;
  String? receivedRefreshToken;

  @override
  Future<Result<AuthTokens>> refreshTokens(String refreshToken) async {
    receivedRefreshToken = refreshToken;
    return _result;
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
  Future<Result<void>> logout({bool revokeRemote = true}) async {
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
