import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/supplier_model.dart';
import 'api_config.dart';

class SupplierService {
  static Future<List<SupplierModel>> getSuppliers() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/suppliers/admin'),
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }

    final List data = jsonDecode(response.body);

    return data
        .map((item) => SupplierModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Future<SupplierModel> createSupplier({
    required String nombre,
    String? contacto,
    String? telefono,
    String? email,
    String? direccion,
    String? notas,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/suppliers/create'),
      headers: ApiConfig.adminHeaders,
      body: jsonEncode({
        'nombre': nombre.trim(),
        'contacto': _clean(contacto),
        'telefono': _clean(telefono),
        'email': _clean(email),
        'direccion': _clean(direccion),
        'notas': _clean(notas),
        'activo': true,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }

    return SupplierModel.fromJson(jsonDecode(response.body));
  }

  static Future<SupplierModel> updateSupplier({
    required int supplierId,
    required String nombre,
    String? contacto,
    String? telefono,
    String? email,
    String? direccion,
    String? notas,
    bool? activo,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/suppliers/update/$supplierId'),
      headers: ApiConfig.adminHeaders,
      body: jsonEncode({
        'nombre': nombre.trim(),
        'contacto': _clean(contacto),
        'telefono': _clean(telefono),
        'email': _clean(email),
        'direccion': _clean(direccion),
        'notas': _clean(notas),
        if (activo != null) 'activo': activo,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }

    return SupplierModel.fromJson(jsonDecode(response.body));
  }

  static Future<SupplierSummaryModel> getSummary(int supplierId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/suppliers/$supplierId/summary'),
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }

    return SupplierSummaryModel.fromJson(jsonDecode(response.body));
  }

  static Future<void> deleteSupplier(int supplierId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/suppliers/delete/$supplierId'),
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }

  static String? _clean(String? value) {
    if (value == null) return null;

    final text = value.trim();

    return text.isEmpty ? null : text;
  }
}
