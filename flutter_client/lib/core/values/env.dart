// lib/app/core/values/env.dart

class Env {
  static const String apiUrl =
      String.fromEnvironment('API_URL', defaultValue: 'http://localhost:5000');
  static const String apiKey =
      String.fromEnvironment('API_KEY', defaultValue: '');
  static const bool isDevelopment =
      bool.fromEnvironment('IS_DEVELOPMENT', defaultValue: false);

  // 다른 환경 변수들을 여기에 추가할 수 있습니다.
}
