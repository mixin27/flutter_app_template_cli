import 'package:__APP_NAME__/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:__APP_NAME__/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:__APP_NAME__/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:__APP_NAME__/features/auth/domain/entities/auth_login_method.dart';
import 'package:__APP_NAME__/features/auth/domain/entities/phone_otp_challenge.dart';
import 'package:app_core/app_core.dart';
import 'package:app_network/app_network.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('returns authenticated session when local tokens exist', () async {
    final repository = AuthRepositoryImpl(
      _FakeAuthRemoteDataSource(),
      localDataSource: _FakeAuthLocalDataSource(
        accessToken: 'access',
        refreshToken: 'refresh',
      ),
    );

    final result = await repository.getCurrentSession();

    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull?.isAuthenticated, isTrue);
    expect(result.dataOrNull?.accessToken, equals('access'));
  });

  test('returns unauthenticated session when local token is missing', () async {
    final repository = AuthRepositoryImpl(
      _FakeAuthRemoteDataSource(),
      localDataSource: _FakeAuthLocalDataSource(),
    );

    final result = await repository.getCurrentSession();

    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull?.isAuthenticated, isFalse);
  });

  test('stores tokens after successful phone OTP verification', () async {
    final local = _FakeAuthLocalDataSource();
    final repository = AuthRepositoryImpl(
      _FakeAuthRemoteDataSource(
        verifyPhoneOtpTokens: const AuthTokens(
          accessToken: 'access',
          refreshToken: 'refresh',
        ),
      ),
      localDataSource: local,
    );

    final result = await repository.verifyPhoneOtp(
      phoneNumber: '+959123456789',
      otpCode: '123456',
      purpose: PhoneOtpPurpose.login,
    );

    expect(result.isSuccess, isTrue);
    expect(local.savedTokens?.accessToken, equals('access'));
    expect(result.dataOrNull?.isAuthenticated, isTrue);
  });

  test('supports email/password login via method API', () async {
    final local = _FakeAuthLocalDataSource();
    final repository = AuthRepositoryImpl(
      _FakeAuthRemoteDataSource(
        loginTokens: const AuthTokens(
          accessToken: 'access',
          refreshToken: 'refresh',
        ),
      ),
      localDataSource: local,
    );

    final result = await repository.loginWithMethod(
      AuthLoginMethod.password(
        identifier: 'hello@example.com',
        password: 'password123',
      ),
    );

    expect(result.isSuccess, isTrue);
    expect(local.savedTokens?.refreshToken, equals('refresh'));
  });

  test('clears local tokens on logout even when remote revoke fails', () async {
    final local = _FakeAuthLocalDataSource(
      accessToken: 'access',
      refreshToken: 'refresh',
    );
    final repository = AuthRepositoryImpl(
      _FakeAuthRemoteDataSource(shouldThrowOnLogout: true),
      localDataSource: local,
    );

    final result = await repository.logout();

    expect(result.isSuccess, isTrue);
    expect(local.didClearTokens, isTrue);
  });

  test('returns success when remote refresh returns tokens', () async {
    final repository = AuthRepositoryImpl(
      _FakeAuthRemoteDataSource(
        refreshTokensResult: const AuthTokens(
          accessToken: 'new-access',
          refreshToken: 'new-refresh',
        ),
      ),
      localDataSource: _FakeAuthLocalDataSource(),
    );

    final result = await repository.refreshTokens('old-refresh');

    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull?.accessToken, equals('new-access'));
    expect(result.dataOrNull?.refreshToken, equals('new-refresh'));
  });

  test('returns failure when remote refresh returns null', () async {
    final repository = AuthRepositoryImpl(
      _FakeAuthRemoteDataSource(),
      localDataSource: _FakeAuthLocalDataSource(),
    );

    final result = await repository.refreshTokens('old-refresh');

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<ServerFailure>());
  });
}

class _FakeAuthLocalDataSource implements AuthLocalDataSource {
  _FakeAuthLocalDataSource({this.accessToken, this.refreshToken});

  String? accessToken;
  String? refreshToken;
  AuthTokens? savedTokens;
  bool didClearTokens = false;

  @override
  Future<void> clearTokens() async {
    didClearTokens = true;
    accessToken = null;
    refreshToken = null;
  }

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    savedTokens = tokens;
    accessToken = tokens.accessToken;
    refreshToken = tokens.refreshToken;
  }
}

class _FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  _FakeAuthRemoteDataSource({
    this.refreshTokensResult,
    this.verifyPhoneOtpTokens,
    this.loginTokens,
    this.shouldThrowOnLogout = false,
  });

  final AuthTokens? refreshTokensResult;
  final AuthTokens? verifyPhoneOtpTokens;
  final AuthTokens? loginTokens;
  final bool shouldThrowOnLogout;

  @override
  Future<AuthTokens?> loginWithMethod(AuthLoginMethod method) async {
    return loginTokens;
  }

  @override
  Future<void> logout({String? refreshToken}) async {
    if (shouldThrowOnLogout) {
      throw Exception('logout failed');
    }
  }

  @override
  Future<AuthTokens?> refreshTokens(String refreshToken) async {
    return refreshTokensResult;
  }

  @override
  Future<PhoneOtpChallenge?> requestPhoneOtp({
    required String phoneNumber,
    required PhoneOtpPurpose purpose,
  }) async {
    return PhoneOtpChallenge(
      phoneNumber: phoneNumber,
      purpose: purpose,
      challengeId: 'challenge-id',
    );
  }

  @override
  Future<AuthTokens?> verifyPhoneOtp({
    required String phoneNumber,
    required String otpCode,
    required PhoneOtpPurpose purpose,
    String? challengeId,
  }) async {
    return verifyPhoneOtpTokens;
  }
}
