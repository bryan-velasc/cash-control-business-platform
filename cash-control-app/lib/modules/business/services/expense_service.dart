import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/expense_model.dart';
import 'api_config.dart';

class ExpenseService {
  static Future<List<ExpenseModel>> getExpenses({
    int limit = 100,
    String? categoria,
  }) async {
    final query = <String, String>{'limit': limit.toString()};

    if (categoria != null && categoria.trim().isNotEmpty) {
      query['categoria'] = categoria.trim();
    }

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/expenses/admin',
    ).replace(queryParameters: query);

    final response = await http.get(uri, headers: ApiConfig.adminHeaders);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((item) => ExpenseModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    throw Exception('Error ${response.statusCode}: ${response.body}');
  }

  static Future<ExpenseModel> getExpense(String expenseId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/expenses/$expenseId'),
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode == 200) {
      return ExpenseModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(response.body)),
      );
    }

    throw Exception('Error ${response.statusCode}: ${response.body}');
  }

  static Future<ExpenseSummaryModel> getSummary() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/expenses/summary'),
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode == 200) {
      return ExpenseSummaryModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(response.body)),
      );
    }

    throw Exception('Error ${response.statusCode}: ${response.body}');
  }

  static Future<ExpenseModel> createExpense({
    required String categoria,
    required String descripcion,
    required double monto,
    required String metodoPago,
    String? referencia,
    String? notas,
    String usuario = 'admin',
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/expenses/create'),
      headers: ApiConfig.adminHeaders,
      body: jsonEncode({
        'categoria': categoria.trim(),
        'descripcion': descripcion.trim(),
        'monto': monto,
        'metodo_pago': metodoPago.trim(),
        'referencia': _clean(referencia),
        'notas': _clean(notas),
        'usuario': usuario.trim(),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ExpenseModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(response.body)),
      );
    }

    throw Exception('Error ${response.statusCode}: ${response.body}');
  }

  static Future<ExpenseModel> updateExpense({
    required String expenseId,
    String? categoria,
    String? descripcion,
    double? monto,
    String? metodoPago,
    String? referencia,
    String? notas,
  }) async {
    final data = <String, dynamic>{};

    if (categoria != null) {
      data['categoria'] = categoria.trim();
    }

    if (descripcion != null) {
      data['descripcion'] = descripcion.trim();
    }

    if (monto != null) {
      data['monto'] = monto;
    }

    if (metodoPago != null) {
      data['metodo_pago'] = metodoPago.trim();
    }

    if (referencia != null) {
      data['referencia'] = _clean(referencia);
    }

    if (notas != null) {
      data['notas'] = _clean(notas);
    }

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/expenses/update/$expenseId'),
      headers: ApiConfig.adminHeaders,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return ExpenseModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(response.body)),
      );
    }

    throw Exception('Error ${response.statusCode}: ${response.body}');
  }

  static Future<void> deleteExpense(String expenseId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/expenses/delete/$expenseId'),
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode == 200) {
      return;
    }

    throw Exception('Error ${response.statusCode}: ${response.body}');
  }

  static String? _clean(String? value) {
    if (value == null) {
      return null;
    }

    final cleaned = value.trim();

    if (cleaned.isEmpty) {
      return null;
    }

    return cleaned;
  }
}
