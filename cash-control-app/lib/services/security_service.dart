import 'dart:convert';

import 'package:http/http.dart' as http;

class SecurityService {
  static const String baseUrl =
      "https://cash-control-3vhg.onrender.com";

  static Future<Map<String, dynamic>> analyzeContent({
    required String email,
    required String content,
    String source = "manual",
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/security/analyze"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "user_email": email,
        "content": content,
        "source": source,
      }),
    );

    print("SECURITY ANALYZE STATUS: ${response.statusCode}");
    print("SECURITY ANALYZE BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      "Error Security Shield: ${response.statusCode} - ${response.body}",
    );
  }

  static Future<List<dynamic>> getLogs(
    String email,
  ) async {
    final encodedEmail = Uri.encodeComponent(email);

    final response = await http.get(
      Uri.parse("$baseUrl/security/logs/$encodedEmail"),
    );

    print("SECURITY LOGS STATUS: ${response.statusCode}");
    print("SECURITY LOGS BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data;
      }

      throw Exception("Respuesta inesperada");
    }

    throw Exception(
      "Error al cargar historial: ${response.body}",
    );
  }
}