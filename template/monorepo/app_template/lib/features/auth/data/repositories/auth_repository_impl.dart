import 'package:app_core/app_core.dart';
import 'package:app_logger/app_logger.dart';
import 'package:app_network/app_network.dart';

import '../../domain/entities/auth_login_method.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/phone_otp_challenge.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl with LoggerMixin implements AuthRepository {
  AuthRepositoryImpl(
    this._remoteDataSource, {
    required AuthLocalDataSource localDataSource,
    AppLogger? logger,
  }) : _localDataSource = localDataSource,
       _logger = logger ?? AppLogger(enabled: false);

  final AuthLocalDataSource _localDataSource;
  final AuthRemoteDataSource _remoteDataSource;
  final AppLogger _logger;

  @override
  AppLogger get logger => _logger;

  @override
  LogContext get logContext => const LogContext('AuthRepo');

  @override
  Future<Result<AuthSession>> getCurrentSession() async {
    try {
      final accessToken = await _localDataSource.readAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        return Result.success(const AuthSession.unauthenticated());
      }

      final refreshToken = await _localDataSource.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return Result.success(const AuthSession.unauthenticated());
      }

      return Result.success(
        AuthSession.authenticated(
          accessToken: accessToken,
          refreshToken: refreshToken,
        ),
      );
    } catch (error) {
      log.error('Failed to resolve local session', error: error);
      return Result.failure(FailureMapper.from(error));
    }
  }

  @override
  Future<Result<PhoneOtpChallenge>> requestPhoneOtp({
    required String phoneNumber,
    required PhoneOtpPurpose purpose,
  }) async {
    try {
      log.debug('Requesting phone OTP ($purpose)');
      final challenge = await _remoteDataSource.requestPhoneOtp(
        phoneNumber: phoneNumber,
        purpose: purpose,
      );
      if (challenge == null) {
        return Result.failure(
          const ServerFailure(message: 'Unable to request OTP.'),
        );
      }

      return Result.success(challenge);
    } catch (error) {
      log.error('Failed to request phone OTP', error: error);
      return Result.failure(FailureMapper.from(error));
    }
  }

  @override
  Future<Result<AuthSession>> verifyPhoneOtp({
    required String phoneNumber,
    required String otpCode,
    required PhoneOtpPurpose purpose,
    String? challengeId,
  }) async {
    try {
      log.debug('Verifying phone OTP ($purpose)');
      final tokens = await _remoteDataSource.verifyPhoneOtp(
        phoneNumber: phoneNumber,
        otpCode: otpCode,
        purpose: purpose,
        challengeId: challengeId,
      );
      if (tokens == null) {
        return Result.failure(
          const ServerFailure(message: 'Invalid OTP or session expired.'),
        );
      }

      await _localDataSource.saveTokens(tokens);
      return Result.success(
        AuthSession.authenticated(
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
        ),
      );
    } catch (error) {
      log.error('Failed to verify phone OTP', error: error);
      return Result.failure(FailureMapper.from(error));
    }
  }

  @override
  Future<Result<AuthSession>> loginWithMethod(AuthLoginMethod method) async {
    try {
      log.debug('Logging in with method: ${method.type.value}');
      final tokens = await _remoteDataSource.loginWithMethod(method);
      if (tokens == null) {
        return Result.failure(
          const ServerFailure(message: 'Unable to sign in with this method.'),
        );
      }

      await _localDataSource.saveTokens(tokens);
      return Result.success(
        AuthSession.authenticated(
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
        ),
      );
    } catch (error) {
      log.error(
        'Failed to login with method: ${method.type.value}',
        error: error,
      );
      return Result.failure(FailureMapper.from(error));
    }
  }

  @override
  Future<Result<void>> logout({bool revokeRemote = true}) async {
    try {
      if (revokeRemote) {
        final refreshToken = await _localDataSource.readRefreshToken();
        try {
          await _remoteDataSource.logout(refreshToken: refreshToken);
        } catch (error) {
          log.warning('Remote logout failed, clearing local session only');
          log.error('Remote logout error', error: error);
        }
      }

      await _localDataSource.clearTokens();
      return Result.success(null);
    } catch (error) {
      log.error('Failed to logout', error: error);
      return Result.failure(FailureMapper.from(error));
    }
  }

  @override
  Future<Result<AuthTokens>> refreshTokens(String refreshToken) async {
    try {
      log.debug('Refreshing access token');
      final tokens = await _remoteDataSource.refreshTokens(refreshToken);
      if (tokens == null) {
        log.warning('Token refresh response was empty');
        return Result.failure(
          const ServerFailure(message: 'Unable to refresh session.'),
        );
      }

      log.info('Token refresh completed');
      return Result.success(tokens);
    } catch (error) {
      log.error('Token refresh failed', error: error);
      return Result.failure(FailureMapper.from(error));
    }
  }
}
