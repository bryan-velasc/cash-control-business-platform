class ApiConfig {
  /*
    ==========================================================
    CASH CONTROL BUSINESS API
    ==========================================================

    DESARROLLO LOCAL:

    flutter run -d chrome \
      --dart-define=API_BASE_URL=http://127.0.0.1:8000 \
      --dart-define=ADMIN_API_TOKEN=TOKEN_LOCAL


    PRODUCCIÓN:

    flutter build apk \
      --dart-define=API_BASE_URL=https://cash-control-business-platform.onrender.com \
      --dart-define=ADMIN_API_TOKEN=TOKEN_PRODUCCION


    IMPORTANTE:

    - API_BASE_URL puede sobrescribirse con --dart-define.
    - ADMIN_API_TOKEN no se guarda directamente en el código.
    - Para producción usa siempre el token nuevo.
    - El token anterior ya no debe reutilizarse.
  */

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://cash-control-business-platform.onrender.com',
  );

  static const String adminToken = String.fromEnvironment(
    'ADMIN_API_TOKEN',
    defaultValue: '',
  );

  static Map<String, String> get adminHeaders {
    if (adminToken.isEmpty) {
      throw Exception(
        'ADMIN_API_TOKEN no está configurado. '
        'Ejecuta Flutter usando '
        '--dart-define=ADMIN_API_TOKEN=TU_TOKEN.',
      );
    }

    return {'Content-Type': 'application/json', 'x-admin-token': adminToken};
  }

  static Map<String, String> get publicHeaders {
    return {'Content-Type': 'application/json'};
  }
}
