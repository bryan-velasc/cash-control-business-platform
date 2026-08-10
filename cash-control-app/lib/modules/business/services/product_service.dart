import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';
import 'api_config.dart';

class ProductService {
  static Future<List<ProductModel>> getPublicProducts() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/products/public'),
      headers: ApiConfig.publicHeaders,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((item) => ProductModel.fromJson(item)).toList();
    }

    throw Exception('Error ${response.statusCode}: ${response.body}');
  }

  static Future<List<ProductModel>> getAdminProducts() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/products/admin'),
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((item) => ProductModel.fromJson(item)).toList();
    }

    throw Exception('Error ${response.statusCode}: ${response.body}');
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
      return ProductModel.fromJson(jsonDecode(response.body));
    }

    throw Exception('Error ${response.statusCode}: ${response.body}');
  }

  static Future<ProductModel> updateProduct({
    required int id,
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
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/products/update/$id'),
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

    if (response.statusCode == 200) {
      return ProductModel.fromJson(jsonDecode(response.body));
    }

    throw Exception('Error ${response.statusCode}: ${response.body}');
  }

  static Future<ProductModel> updateProductStock({
    required int id,
    required int stock,
  }) async {
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/products/stock/$id'),
      headers: ApiConfig.adminHeaders,
      body: jsonEncode({'stock': stock}),
    );

    if (response.statusCode == 200) {
      return ProductModel.fromJson(jsonDecode(response.body));
    }

    throw Exception('Error ${response.statusCode}: ${response.body}');
  }

  static Future<void> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/products/delete/$id'),
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode == 200) {
      return;
    }

    throw Exception('Error ${response.statusCode}: ${response.body}');
  }
}
