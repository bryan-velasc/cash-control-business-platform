import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/sale_model.dart';
import 'api_config.dart';

class SaleService {
  static Future<List<SaleModel>> getSales({
    int limit = 100,
  }) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/sales/admin?limit=$limit',
      ),
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data
          .map(
            (item) => SaleModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    }

    throw Exception(
      'Error ${response.statusCode}: ${response.body}',
    );
  }

  static Future<SaleModel> getSale(
    String saleId,
  ) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/sales/$saleId',
      ),
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode == 200) {
      return SaleModel.fromJson(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Error ${response.statusCode}: ${response.body}',
    );
  }

  static Future<SalesSummaryModel> getSummary() async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/sales/summary',
      ),
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode == 200) {
      return SalesSummaryModel.fromJson(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Error ${response.statusCode}: ${response.body}',
    );
  }

  static Future<SaleModel> createSale({
    required List<Map<String, dynamic>> items,
    required String metodoPago,
    int? customerId,
    String? notas,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${ApiConfig.baseUrl}/sales/create',
      ),
      headers: ApiConfig.adminHeaders,
      body: jsonEncode({
        'items': items,
        'metodo_pago': metodoPago,
        'customer_id': customerId,
        'notas': notas,
        'usuario': 'admin',
      }),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return SaleModel.fromJson(
        jsonDecode(response.body),
      );
    }

    throw Exception(
      'Error ${response.statusCode}: ${response.body}',
    );
  }
}