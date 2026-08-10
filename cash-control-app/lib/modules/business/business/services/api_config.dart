class ApiConfig {
  /*
    URLs según entorno:

    Flutter Web:
    http://127.0.0.1:8000

    Emulador Android:
    http://10.0.2.2:8000

    Celular físico:
    http://IP_DE_TU_PC:8000

    Producción:
    https://tu-backend-en-render.onrender.com
  */

  static const String baseUrl = 'http://10.0.2.2:8000';

  static const String adminToken = 'cama_75_pol_*';

  static Map<String, String> get adminHeaders {
    return {'Content-Type': 'application/json', 'x-admin-token': adminToken};
  }

  static Map<String, String> get publicHeaders {
    return {'Content-Type': 'application/json'};
  }
}
