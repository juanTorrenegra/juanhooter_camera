import 'package:dio/dio.dart';

/// Attaches device/pilot identity now; later this is where Cognito JWTs go.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.pilotId,
    this.accessToken,
  });

  final String Function() pilotId;
  final String? Function()? accessToken;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['X-Pilot-Id'] = pilotId();
    options.headers['X-Client'] = 'darbala/1.0';
    final token = accessToken?.call();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
