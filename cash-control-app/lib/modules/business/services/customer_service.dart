import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/customer_model.dart';
import 'api_config.dart';

class CustomerService {
  static Future<List<CustomerModel>> getCustomers() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/customers/admin'),
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al obtener clientes: '
        '${response.statusCode} ${response.body}',
      );
    }

    final dynamic decoded = jsonDecode(response.body);

    if (decoded is! List) {
      throw Exception('La respuesta de clientes no tiene el formato esperado.');
    }

    return decoded
        .map(
          (item) =>
              CustomerModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  static Future<CustomerModel> getCustomer(int customerId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/customers/$customerId'),
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al obtener cliente: ${response.body}');
    }

    return CustomerModel.fromJson(
      Map<String, dynamic>.from(jsonDecode(response.body) as Map),
    );
  }

  static Future<CustomerModel> createCustomer({
    required String nombre,
    String? telefono,
    String? alias,
    String? notas,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/customers/create'),
      headers: ApiConfig.adminHeaders,
      body: jsonEncode({
        'nombre': nombre.trim(),
        'telefono': _nullableText(telefono),
        'alias': _nullableText(alias),
        'notas': _nullableText(notas),
        'activo': true,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al crear cliente: ${response.body}');
    }

    return CustomerModel.fromJson(
      Map<String, dynamic>.from(jsonDecode(response.body) as Map),
    );
  }

  static Future<CustomerModel> updateCustomer({
    required int customerId,
    String? nombre,
    String? telefono,
    String? alias,
    String? notas,
    bool? activo,
  }) async {
    final body = <String, dynamic>{};

    if (nombre != null) {
      body['nombre'] = nombre.trim();
    }

    if (telefono != null) {
      body['telefono'] = _nullableText(telefono);
    }

    if (alias != null) {
      body['alias'] = _nullableText(alias);
    }

    if (notas != null) {
      body['notas'] = _nullableText(notas);
    }

    if (activo != null) {
      body['activo'] = activo;
    }

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/customers/update/$customerId'),
      headers: ApiConfig.adminHeaders,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar cliente: ${response.body}');
    }

    return CustomerModel.fromJson(
      Map<String, dynamic>.from(jsonDecode(response.body) as Map),
    );
  }

  static Future<CustomerSummaryModel> getCustomerSummary(int customerId) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/customers/'
        '$customerId/summary',
      ),
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al obtener resumen del cliente: '
        '${response.body}',
      );
    }

    return CustomerSummaryModel.fromJson(
      Map<String, dynamic>.from(jsonDecode(response.body) as Map),
    );
  }

  static Future<void> deleteCustomer(int customerId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/customers/delete/$customerId'),
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al desactivar cliente: ${response.body}');
    }
  }

  static String? _nullableText(String? value) {
    if (value == null) return null;

    final cleaned = value.trim();

    return cleaned.isEmpty ? null : cleaned;
  }
}
