/// Backend contract. Swap [baseUrl] to point at API Gateway later:
/// `flutter run --dart-define=API_BASE_URL=https://api.example.com`
class ApiConfig {
  const ApiConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 8),
    this.receiveTimeout = const Duration(seconds: 12),
  });

  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  factory ApiConfig.fromEnvironment() {
    return const ApiConfig(
      baseUrl: String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://jsonplaceholder.typicode.com',
      ),
    );
  }
}

abstract final class ApiPaths {
  static const users = '/users';
  static const posts = '/posts';
  static const transmission = '/posts/1';
}
