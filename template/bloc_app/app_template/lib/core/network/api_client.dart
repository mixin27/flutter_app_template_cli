import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient(this._client, this._config);

  final http.Client _client;
  final AppConfig _config;

  bool get _useMockApi => _config.useMockApi;

  Future<Map<String, dynamic>> getJson(String path, {String? token}) async {
    if (_useMockApi) {
      return _mockGet(path);
    }

    final response = await _client.get(
      _resolve(path),
      headers: _headers(token),
    );

    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    if (_useMockApi) {
      return _mockPost(path, body);
    }

    final response = await _client.post(
      _resolve(path),
      headers: _headers(token),
      body: jsonEncode(body),
    );

    return _parseResponse(response);
  }

  Uri _resolve(String path) {
    final base = _config.apiBaseUrl.endsWith('/')
        ? _config.apiBaseUrl.substring(0, _config.apiBaseUrl.length - 1)
        : _config.apiBaseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$normalizedPath');
  }

  Map<String, String> _headers(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return <String, dynamic>{};
      }
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      throw ApiException('Unexpected response format');
    }

    throw ApiException(
      response.body.isEmpty ? 'Request failed' : response.body,
      statusCode: response.statusCode,
    );
  }

  Map<String, dynamic> _mockPost(String path, Map<String, dynamic> body) {
    switch (path) {
      case '/auth/login':
        return {
          'token': 'mock-token',
          'user': {
            'id': 'user-123',
            'name': 'Demo User',
            'email': body['email'] ?? 'demo@example.com',
          },
        };
      default:
        throw ApiException('No mock response for $path');
    }
  }

  Map<String, dynamic> _mockGet(String path) {
    switch (path) {
      case '/profile':
        return {
          'id': 'user-123',
          'name': 'Demo User',
          'email': 'demo@example.com',
          'avatarUrl': null,
          'updatedAt': DateTime.now().toIso8601String(),
        };
      default:
        throw ApiException('No mock response for $path');
    }
  }
}
