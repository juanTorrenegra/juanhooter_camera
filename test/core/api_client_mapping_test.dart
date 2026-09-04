import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:juanshooter/core/error/app_failure.dart';
import 'package:juanshooter/core/network/api_client.dart';

void main() {
  RequestOptions options() => RequestOptions(path: '/users');

  test('maps timeouts to TimeoutFailure', () {
    final failure = mapDioException(
      DioException(
        requestOptions: options(),
        type: DioExceptionType.connectionTimeout,
      ),
    );
    expect(failure, isA<TimeoutFailure>());
  });

  test('maps 401 to UnauthorizedFailure', () {
    final failure = mapDioException(
      DioException(
        requestOptions: options(),
        type: DioExceptionType.badResponse,
        response: Response<void>(
          requestOptions: options(),
          statusCode: 401,
        ),
      ),
    );
    expect(failure, isA<UnauthorizedFailure>());
  });

  test('maps 503 to ServerFailure with status', () {
    final failure = mapDioException(
      DioException(
        requestOptions: options(),
        type: DioExceptionType.badResponse,
        response: Response<void>(
          requestOptions: options(),
          statusCode: 503,
        ),
      ),
    );
    expect(failure, isA<ServerFailure>());
    expect((failure as ServerFailure).statusCode, 503);
  });
}
