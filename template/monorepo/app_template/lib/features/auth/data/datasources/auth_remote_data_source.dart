import 'package:app_network/app_network.dart';

import '../../domain/entities/auth_login_method.dart';
import '../../domain/entities/phone_otp_challenge.dart';
import '../models/phone_otp_challenge_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthTokens?> refreshTokens(String refreshToken);

  Future<PhoneOtpChallenge?> requestPhoneOtp({
    required String phoneNumber,
    required PhoneOtpPurpose purpose,
  });

  Future<AuthTokens?> verifyPhoneOtp({
    required String phoneNumber,
    required String otpCode,
    required PhoneOtpPurpose purpose,
    String? challengeId,
  });

  Future<AuthTokens?> loginWithMethod(AuthLoginMethod method);

  Future<void> logout({String? refreshToken});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  static const String _refreshPath = '/auth/refresh';
  static const String _requestOtpPath = '/auth/otp/request';
  static const String _verifyOtpPath = '/auth/otp/verify';
  static const String _loginPath = '/auth/login';
  static const String _logoutPath = '/auth/logout';

  @override
  Future<AuthTokens?> refreshTokens(String refreshToken) async {
    try {
      final response = await _apiClient.postMap(
        _refreshPath,
        data: <String, dynamic>{'refreshToken': refreshToken},
        skipAuth: true,
      );

      return _mapTokens(response, fallbackRefreshToken: refreshToken);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<PhoneOtpChallenge?> requestPhoneOtp({
    required String phoneNumber,
    required PhoneOtpPurpose purpose,
  }) async {
    try {
      final response = await _apiClient.postMap(
        _requestOtpPath,
        data: <String, dynamic>{
          'phoneNumber': phoneNumber,
          'purpose': purpose.value,
        },
        skipAuth: true,
      );

      final payload = _extractPayload(response);
      return PhoneOtpChallengeModel.fromJson(
        payload,
        phoneNumber: phoneNumber,
        purpose: purpose,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthTokens?> verifyPhoneOtp({
    required String phoneNumber,
    required String otpCode,
    required PhoneOtpPurpose purpose,
    String? challengeId,
  }) async {
    try {
      final response = await _apiClient.postMap(
        _verifyOtpPath,
        data: <String, dynamic>{
          'phoneNumber': phoneNumber,
          'otpCode': otpCode,
          'purpose': purpose.value,
          if (challengeId != null && challengeId.isNotEmpty)
            'challengeId': challengeId,
        },
        skipAuth: true,
      );

      return _mapTokens(response);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthTokens?> loginWithMethod(AuthLoginMethod method) async {
    try {
      final response = await _apiClient.postMap(
        _loginPath,
        data: <String, dynamic>{
          'method': _resolveMethod(method),
          ...method.payload,
        },
        skipAuth: true,
      );

      return _mapTokens(response);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout({String? refreshToken}) {
    return _apiClient.postVoid(
      _logoutPath,
      data: <String, dynamic>{
        if (refreshToken != null && refreshToken.isNotEmpty)
          'refreshToken': refreshToken,
      },
    );
  }

  AuthTokens? _mapTokens(
    Map<String, dynamic> response, {
    String? fallbackRefreshToken,
  }) {
    final payload = _extractPayload(response);
    final accessToken =
        _readString(payload, 'accessToken') ??
        _readString(payload, 'access_token') ??
        _readString(payload, 'token');

    final resolvedRefreshToken =
        _readString(payload, 'refreshToken') ??
        _readString(payload, 'refresh_token') ??
        fallbackRefreshToken;

    if (accessToken == null || accessToken.isEmpty) {
      return null;
    }

    if (resolvedRefreshToken == null || resolvedRefreshToken.isEmpty) {
      return null;
    }

    return AuthTokens(
      accessToken: accessToken,
      refreshToken: resolvedRefreshToken,
    );
  }

  String _resolveMethod(AuthLoginMethod method) {
    if (method.type == AuthMethodType.custom) {
      final customMethod = method.payload['method'];
      if (customMethod is String && customMethod.isNotEmpty) {
        return customMethod;
      }
    }

    return method.type.value;
  }

  Map<String, dynamic> _extractPayload(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    final result = response['result'];
    if (result is Map<String, dynamic>) {
      return result;
    }

    if (result is Map) {
      return Map<String, dynamic>.from(result);
    }

    return response;
  }

  String? _readString(Map<String, dynamic> payload, String key) {
    final value = payload[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }

    return null;
  }
}
