import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';
import '../models/stock_movement_model.dart';
import 'api_config.dart';

class InventoryService {
  static Future<StockMovementModel> adjustStock({
    required int productId,
    required String tipo,
    required int cantidad,
    required String motivo,
    String usuario = 'admin',
    String? referencia,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/inventory/stock/adjust/$productId'),
      headers: ApiConfig.adminHeaders,
      body: jsonEncode({
        'tipo': tipo,
        'cantidad': cantidad,
        'motivo': motivo,
        'usuario': usuario,
        'referencia': referencia,
      }),
    );

    if (response.statusCode == 200) {
      return StockMovementModel.fromJson(jsonDecode(response.body));
    }

    throw Exception('Error ${response.statusCode}: ${response.body}');
  }

  static Future<List<StockMovementModel>> getHistory({
    int? productId,
    int limit = 100,
  }) async {
    final params = <String, String>{'limit': limit.toString()};

    if (productId != null) {
      params['product_id'] = productId.toString();
    }

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/inventory/stock/history',
    ).replace(queryParameters: params);

    final response = await http.get(uri, headers: ApiConfig.adminHeaders);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List movements = data['movimientos'] as List? ?? [];

      return movements
          .map(
            (item) =>
                StockMovementModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    throw Exception('Error ${response.statusCode}: ${response.body}');
  }

  static Future<List<ProductModel>> getLowStockProducts() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/inventory/stock/low'),
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data
          .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    throw Exception('Error ${response.statusCode}: ${response.body}');
  }
}
