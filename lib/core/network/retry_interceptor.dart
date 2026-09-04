import 'package:dio/dio.dart';

/// Retries idempotent GETs on transient network / 5xx failures.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxRetries = 2,
  });

  final Dio dio;
  final int maxRetries;
  static const _attemptKey = 'retryAttempt';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    final attempt = (err.requestOptions.extra[_attemptKey] as int?) ?? 0;
    if (attempt >= maxRetries) {
      return handler.next(err);
    }

    err.requestOptions.extra[_attemptKey] = attempt + 1;
    await Future<void>.delayed(Duration(milliseconds: 280 * (attempt + 1)));

    try {
      final response = await dio.fetch<dynamic>(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _shouldRetry(DioException err) {
    if (err.requestOptions.method.toUpperCase() != 'GET') return false;
    return switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.transformTimeout ||
      DioExceptionType.connectionError => true,
      DioExceptionType.badResponse =>
        (err.response?.statusCode ?? 0) >= 500,
      _ => false,
    };
  }
}
