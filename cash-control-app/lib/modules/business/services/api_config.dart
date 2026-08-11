class ApiConfig {
  /*
    DESARROLLO:

    flutter run -d chrome \
      --dart-define=API_BASE_URL=http://127.0.0.1:8000 \
      --dart-define=ADMIN_API_TOKEN=TOKEN_LOCAL

    PRODUCCIÓN:

    flutter build apk \
      --dart-define=API_BASE_URL=https://TU-BACKEND.onrender.com \
      --dart-define=ADMIN_API_TOKEN=TOKEN_PRODUCCION
  */

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static const String adminToken = String.fromEnvironment(
    'ADMIN_API_TOKEN',
    defaultValue: '',
  );

  static Map<String, String> get adminHeaders {
    if (adminToken.isEmpty) {
      throw Exception(
        'ADMIN_API_TOKEN no está configurado.',
      );
    }

    return {
      'Content-Type': 'application/json',
      'x-admin-token': adminToken,
    };
  }

  static Map<String, String> get publicHeaders {
    return {
      'Content-Type': 'application/json',
    };
  }
}