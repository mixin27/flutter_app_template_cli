import 'package:__APP_NAME__/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:app_network/app_network.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthRemoteDataSourceImpl.refreshTokens', () {
    test('returns tokens from top-level payload', () async {
      final dataSource = AuthRemoteDataSourceImpl(
        _FakeApiClient(
          payload: <String, dynamic>{
            'accessToken': 'new-access',
            'refreshToken': 'new-refresh',
          },
        ),
      );

      final result = await dataSource.refreshTokens('old-refresh');

      expect(result, isNotNull);
      expect(result?.accessToken, equals('new-access'));
      expect(result?.refreshToken, equals('new-refresh'));
    });

    test('returns tokens from nested data payload', () async {
      final dataSource = AuthRemoteDataSourceImpl(
        _FakeApiClient(
          payload: <String, dynamic>{
            'data': <String, dynamic>{'access_token': 'new-access'},
          },
        ),
      );

      final result = await dataSource.refreshTokens('old-refresh');

      expect(result, isNotNull);
      expect(result?.accessToken, equals('new-access'));
      expect(result?.refreshToken, equals('old-refresh'));
    });

    test('returns null when access token is missing', () async {
      final dataSource = AuthRemoteDataSourceImpl(
        _FakeApiClient(
          payload: <String, dynamic>{'refreshToken': 'new-refresh'},
        ),
      );

      final result = await dataSource.refreshTokens('old-refresh');

      expect(result, isNull);
    });

    test('returns null when API throws', () async {
      final dataSource = AuthRemoteDataSourceImpl(
        _FakeApiClient(payload: <String, dynamic>{}, shouldThrow: true),
      );

      final result = await dataSource.refreshTokens('old-refresh');

      expect(result, isNull);
    });
  });
}

class _FakeApiClient extends ApiClient {
  _FakeApiClient({required this.payload, this.shouldThrow = false})
    : super(Dio());

  final Map<String, dynamic> payload;
  final bool shouldThrow;

  @override
  Future<Map<String, dynamic>> postMap(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    bool skipAuth = false,
  }) async {
    if (shouldThrow) {
      throw Exception('refresh failed');
    }

    return payload;
  }
}
