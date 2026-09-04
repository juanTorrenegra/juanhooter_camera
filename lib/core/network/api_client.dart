import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:juanshooter/core/error/app_failure.dart';
import 'package:juanshooter/core/network/api_config.dart';
import 'package:juanshooter/core/network/auth_interceptor.dart';
import 'package:juanshooter/core/network/retry_interceptor.dart';

class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  factory ApiClient.create({
    required ApiConfig config,
    required String Function() pilotId,
    String? Function()? accessToken,
    Dio? dio,
  }) {
    final client = dio ??
        Dio(
          BaseOptions(
            baseUrl: config.baseUrl,
            connectTimeout: config.connectTimeout,
            receiveTimeout: config.receiveTimeout,
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        );

    client.interceptors.addAll([
      AuthInterceptor(pilotId: pilotId, accessToken: accessToken),
      RetryInterceptor(dio: client),
      if (kDebugMode)
        LogInterceptor(
          requestHeader: false,
          requestBody: true,
          responseHeader: false,
          responseBody: false,
        ),
    ]);

    return ApiClient(client);
  }

  Future<T> get<T>(
    String path, {
    required T Function(dynamic json) parse,
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.get<dynamic>(path, queryParameters: query);
      return parse(response.data);
    } on DioException catch (error) {
      throw mapDioException(error);
    } on AppFailure {
      rethrow;
    } catch (error, stack) {
      throw ParseFailure('Unexpected response shape', cause: (error, stack));
    }
  }

  Future<T> post<T>(
    String path, {
    required Map<String, dynamic> body,
    required T Function(dynamic json) parse,
  }) async {
    try {
      final response = await _dio.post<dynamic>(path, data: body);
      return parse(response.data);
    } on DioException catch (error) {
      throw mapDioException(error);
    } on AppFailure {
      rethrow;
    } catch (error, stack) {
      throw ParseFailure('Unexpected response shape', cause: (error, stack));
    }
  }
}

@visibleForTesting
AppFailure mapDioException(DioException error) {
  return switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.transformTimeout =>
      TimeoutFailure('The outpost did not answer in time', cause: error),
    DioExceptionType.connectionError ||
    DioExceptionType.unknown =>
      NetworkFailure('No link to the outpost', cause: error),
    DioExceptionType.badResponse => _fromStatus(error),
    DioExceptionType.cancel =>
      NetworkFailure('Request cancelled', cause: error),
    DioExceptionType.badCertificate =>
      NetworkFailure('TLS certificate rejected', cause: error),
  };
}

AppFailure _fromStatus(DioException error) {
  final code = error.response?.statusCode;
  if (code == 401 || code == 403) {
    return UnauthorizedFailure('Pilot identity rejected', cause: error);
  }
  return ServerFailure(
    'Outpost returned HTTP $code',
    statusCode: code,
    cause: error,
  );
}
