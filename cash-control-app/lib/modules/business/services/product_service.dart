import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/api_message_model.dart';
import '../models/product_model.dart';
import 'api_config.dart';

class ProductService {
  static Future<List<ProductModel>> getPublicProducts() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/products/public'),
      headers: ApiConfig.publicHeaders,
    );

    final data = _decodeResponse(response);

    if (data is List) {
      return data
          .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    throw Exception('La API no devolvió una lista de productos públicos.');
  }

  static Future<List<ProductModel>> getAdminProducts() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/products/admin'),
      headers: ApiConfig.adminHeaders,
    );

    final data = _decodeResponse(response);

    if (data is List) {
      return data
          .map((item) => ProductModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    throw Exception('La API no devolvió una lista de productos administrativos.');
  }

  static Future<ProductModel> getProductById(int productId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/products/$productId'),
      headers: ApiConfig.publicHeaders,
    );

    final data = _decodeResponse(response);

    return ProductModel.fromJson(Map<String, dynamic>.from(data));
  }

  static Future<ProductModel> createProduct({
  required String nombre,
  required String categoria,
  required double precio,
  required String imagen,
  required int stock,
  required bool activo,
  double? precioCompra,
  String? proveedor,
  int? stockMinimo,
}) async {
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}/products/create'),
    headers: ApiConfig.adminHeaders,
    body: jsonEncode({
      'nombre': nombre,
      'categoria': categoria,
      'precio': precio,
      'imagen': imagen,
      'stock': stock,
      'activo': activo,
      'precio_compra': precioCompra,
      'proveedor': proveedor,
      'stock_minimo': stockMinimo ?? 0,
    }),
  );

  if (response.statusCode == 201) {
    return ProductModel.fromJson(
      jsonDecode(response.body),
    );
  }

  throw Exception(
    'Error ${response.statusCode}: ${response.body}',
  );
}

  static Future<ProductModel> updateProduct({
    required int productId,
    required Map<String, dynamic> data,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/products/update/$productId'),
      headers: ApiConfig.adminHeaders,
      body: jsonEncode(data),
    );

    final decoded = _decodeResponse(response);

    return ProductModel.fromJson(Map<String, dynamic>.from(decoded));
  }

  static Future<ProductModel> updateProductStock({
    required int productId,
    required int stock,
  }) async {
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/products/stock/$productId'),
      headers: ApiConfig.adminHeaders,
      body: jsonEncode({
        'stock': stock,
      }),
    );

    final data = _decodeResponse(response);

    return ProductModel.fromJson(Map<String, dynamic>.from(data));
  }

  static Future<ApiMessageModel> deleteProduct(int productId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/products/delete/$productId'),
      headers: ApiConfig.adminHeaders,
    );

    final data = _decodeResponse(response);

    return ApiMessageModel.fromJson(Map<String, dynamic>.from(data));
  }

  static dynamic _decodeResponse(http.Response response) {
    final body = response.body.isEmpty ? null : jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    throw Exception(
      'Error ${response.statusCode}: ${response.body}',
    );
  }
  static Future<ProductModel> updateProductStock({
  required int id,
  required int stock,
}) async {
  final response = await http.patch(
    Uri.parse('${ApiConfig.baseUrl}/products/stock/$id'),
    headers: ApiConfig.adminHeaders,
    body: jsonEncode({
      'stock': stock,
    }),
  );

  if (response.statusCode == 200) {
    return ProductModel.fromJson(
      jsonDecode(response.body),
    );
  }

  throw Exception(
    'Error ${response.statusCode}: ${response.body}',
  );
}

  static Future<List<ProductModel>> getLowStockProducts() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/products/stock/low'),
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