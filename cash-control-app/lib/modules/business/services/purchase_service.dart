import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/purchase_model.dart';
import 'api_config.dart';

class PurchaseService {
  static Future<List<PurchaseModel>> getPurchases({int limit = 100}) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/purchases/admin?limit=$limit'),
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }

    final List data = jsonDecode(response.body);

    return data
        .map((item) => PurchaseModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Future<PurchaseModel> getPurchase(String purchaseId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/purchases/$purchaseId'),
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }

    return PurchaseModel.fromJson(jsonDecode(response.body));
  }

  static Future<PurchaseSummaryModel> getSummary() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/purchases/summary'),
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }

    return PurchaseSummaryModel.fromJson(jsonDecode(response.body));
  }

  static Future<PurchaseModel> createPurchase({
    required int supplierId,
    required List<Map<String, dynamic>> items,
    String? referencia,
    String? notas,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/purchases/create'),
      headers: ApiConfig.adminHeaders,
      body: jsonEncode({
        'supplier_id': supplierId,
        'items': items,
        'referencia': referencia,
        'notas': notas,
        'usuario': 'admin',
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }

    return PurchaseModel.fromJson(jsonDecode(response.body));
  }
}
