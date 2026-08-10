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
    required String usuario,
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

    final data = _decodeResponse(response);

    return StockMovementModel.fromJson(Map<String, dynamic>.from(data));
  }

  static Future<List<StockMovementModel>> getStockHistory({
    int? productId,
    int limit = 100,
  }) async {
    final queryParameters = <String, String>{'limit': limit.toString()};

    if (productId != null) {
      queryParameters['product_id'] = productId.toString();
    }

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/inventory/stock/history',
    ).replace(queryParameters: queryParameters);

    final response = await http.get(uri, headers: ApiConfig.adminHeaders);

    final data = _decodeResponse(response);

    if (data is List) {
      return data
          .map(
            (item) =>
                StockMovementModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    if (data is Map && data['movements'] is List) {
      final movements = data['movements'] as List;

      return movements
          .map(
            (item) =>
                StockMovementModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    throw Exception('La API no devolvió historial de movimientos.');
  }

  static Future<List<ProductModel>> getLowStockProducts() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/inventory/stock/low'),
      headers: ApiConfig.adminHeaders,
    );

    final data = _decodeResponse(response);

    if (data is List) {
      return data
          .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    throw Exception('La API no devolvió productos con stock bajo.');
  }

  static dynamic _decodeResponse(http.Response response) {
    final body = response.body.isEmpty ? null : jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    throw Exception('Error ${response.statusCode}: ${response.body}');
  }
}
