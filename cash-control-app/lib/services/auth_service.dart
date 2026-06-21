import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {

  static const String baseUrl =
    "https://cash-control-3vhg.onrender.com";

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {

    final response = await http.post(

      Uri.parse("$baseUrl/login"),

      headers: {
        "Content-Type": "application/json"
      },

      body: jsonEncode({

        "email": email,
        "password": password

      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {

    final response = await http.post(

      Uri.parse("$baseUrl/register"),

      headers: {
        "Content-Type": "application/json"
      },

      body: jsonEncode({

        "name": name,
        "email": email,
        "password": password

      }),
    );

    return jsonDecode(response.body);
  }
}