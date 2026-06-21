import 'dart:convert';
import 'package:http/http.dart' as http;

class OCRService {
  static const String baseUrl =
      "https://cash-control-3vhg.onrender.com";

  static Future<Map<String, dynamic>> analyzeText(
    String text,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/ocr/analyze"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "text": text,
      }),
    );

    print("OCR ANALYZE STATUS: ${response.statusCode}");
    print("OCR ANALYZE BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Error OCR backend: ${response.statusCode} - ${response.body}",
      );
    }
  }
}