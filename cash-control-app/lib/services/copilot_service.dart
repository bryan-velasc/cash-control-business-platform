import 'dart:convert';
import 'package:http/http.dart' as http;

class CopilotService {
  static const String baseUrl =
      "https://cash-control-3vhg.onrender.com";

  static Future<Map<String, dynamic>> sendMessage({
    required String email,
    required String message,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/copilot/chat"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "user_email": email,
        "message": message,
      }),
    );

    print("COPILOT STATUS: ${response.statusCode}");
    print("COPILOT BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      "Error Copilot: ${response.statusCode} - ${response.body}",
    );
  }
}