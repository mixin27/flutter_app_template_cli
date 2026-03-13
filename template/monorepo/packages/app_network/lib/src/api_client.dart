import 'package:app_core/app_core.dart';
import 'package:dio/dio.dart';

import 'auth/network_request_flags.dart';

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<List<Map<String, dynamic>>> getList(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool skipAuth = false,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: _options(skipAuth: skipAuth),
      );

      _assertSuccessStatus(response.statusCode);

      final data = response.data;
      final list = _extractList(data);

      return list.map(_normalizeMap).toList(growable: false);
    } on DioException catch (error) {
      throw _mapDioException(error);
    } on FormatException catch (error) {
      throw ParseException(error.message);
    } catch (error) {
      throw UnknownException(error.toString());
    }
  }

  Future<void> patch(
    String path, {
    Map<String, dynamic>? data,
    bool skipAuth = false,
  }) async {
    try {
      final response = await _dio.patch<dynamic>(
        path,
        data: data,
        options: _options(skipAuth: skipAuth),
      );
      _assertSuccessStatus(response.statusCode);
    } on DioException catch (error) {
      throw _mapDioException(error);
    } catch (error) {
      throw UnknownException(error.toString());
    }
  }

  Future<Map<String, dynamic>> postMap(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    bool skipAuth = false,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _options(skipAuth: skipAuth),
      );

      _assertSuccessStatus(response.statusCode);
      return _normalizeMap(response.data);
    } on DioException catch (error) {
      throw _mapDioException(error);
    } on FormatException catch (error) {
      throw ParseException(error.message);
    } catch (error) {
      throw UnknownException(error.toString());
    }
  }

  Future<void> postVoid(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    bool skipAuth = false,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _options(skipAuth: skipAuth),
      );

      _assertSuccessStatus(response.statusCode);
    } on DioException catch (error) {
      throw _mapDioException(error);
    } catch (error) {
      throw UnknownException(error.toString());
    }
  }

  void _assertSuccessStatus(int? statusCode) {
    if (statusCode == null) {
      throw const ServerException(message: 'Missing response status code.');
    }

    if (statusCode < 200 || statusCode >= 300) {
      throw ServerException(
        message: 'Unexpected response status: $statusCode',
        statusCode: statusCode,
      );
    }
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List<dynamic>) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      final payload = data['data'];
      if (payload is List<dynamic>) {
        return payload;
      }

      final items = data['items'];
      if (items is List<dynamic>) {
        return items;
      }
    }

    throw const FormatException('Response payload is not a list.');
  }

  Map<String, dynamic> _normalizeMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    throw const FormatException('List item is not an object.');
  }

  AppException _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const NetworkException('Please check your internet connection.');
      case DioExceptionType.cancel:
        return const NetworkException('Request was cancelled.');
      case DioExceptionType.badResponse:
        return ServerException(
          message: _extractMessage(error.response?.data),
          statusCode: error.response?.statusCode,
        );
    }
  }

  String _extractMessage(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final message = payload['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    return 'Server request failed.';
  }

  Options? _options({required bool skipAuth}) {
    if (!skipAuth) {
      return null;
    }

    return Options(extra: const {NetworkRequestFlags.skipAuth: true});
  }
}
