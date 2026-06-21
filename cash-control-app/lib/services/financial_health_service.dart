import 'dart:convert';

import 'package:http/http.dart' as http;

class FinancialHealthService {
  static const String baseUrl =
      "https://cash-control-3vhg.onrender.com";

  static Future<Map<String, dynamic>> getFinancialHealth(
    String email,
  ) async {
    final encodedEmail = Uri.encodeComponent(email);

    final response = await http.get(
      Uri.parse(
        "$baseUrl/financial-health/$encodedEmail",
      ),
    );

    print(
      "FINANCIAL HEALTH STATUS: ${response.statusCode}",
    );

    print(
      "FINANCIAL HEALTH BODY: ${response.body}",
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      "Error al cargar salud financiera: ${response.body}",
    );
  }
}