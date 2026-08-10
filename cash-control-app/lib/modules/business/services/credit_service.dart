import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/credit_model.dart';
import '../models/credit_payment_model.dart';
import 'api_config.dart';

class CreditService {
  static Future<List<CreditModel>> getCredits() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/credits/admin'),
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception(_getError(response));
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map((item) => CreditModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Future<CreditModel> getCredit(int creditId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/credits/$creditId'),
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception(_getError(response));
    }

    return CreditModel.fromJson(
      Map<String, dynamic>.from(jsonDecode(response.body)),
    );
  }

  static Future<List<CreditModel>> getCustomerCredits(int customerId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/credits/customer/$customerId'),
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception(_getError(response));
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map((item) => CreditModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static Future<CreditModel> createCredit({
    required int customerId,
    required String concepto,
    required double montoTotal,
    DateTime? fechaLimite,
    String? notas,
  }) async {
    final body = {
      'customer_id': customerId,
      'concepto': concepto.trim(),
      'monto_total': montoTotal,
      'fecha_limite': fechaLimite == null ? null : _formatDate(fechaLimite),
      'notas': _nullableText(notas),
      'usuario': 'admin',
    };

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/credits/create'),
      headers: ApiConfig.adminHeaders,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_getError(response));
    }

    return CreditModel.fromJson(
      Map<String, dynamic>.from(jsonDecode(response.body)),
    );
  }

  static Future<CreditModel> updateCredit({
    required int creditId,
    String? concepto,
    DateTime? fechaLimite,
    String? notas,
    String? estado,
  }) async {
    final body = <String, dynamic>{};

    if (concepto != null) {
      body['concepto'] = concepto.trim();
    }

    if (fechaLimite != null) {
      body['fecha_limite'] = _formatDate(fechaLimite);
    }

    if (notas != null) {
      body['notas'] = _nullableText(notas);
    }

    if (estado != null) {
      body['estado'] = estado;
    }

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/credits/update/$creditId'),
      headers: ApiConfig.adminHeaders,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception(_getError(response));
    }

    return CreditModel.fromJson(
      Map<String, dynamic>.from(jsonDecode(response.body)),
    );
  }

  static Future<CreditPaymentModel> registerPayment({
    required int creditId,
    required double monto,
    String metodoPago = 'efectivo',
    String? nota,
  }) async {
    final body = {
      'monto': monto,
      'metodo_pago': metodoPago,
      'nota': _nullableText(nota),
      'usuario': 'admin',
    };

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/credits/pay/$creditId'),
      headers: ApiConfig.adminHeaders,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_getError(response));
    }

    return CreditPaymentModel.fromJson(
      Map<String, dynamic>.from(jsonDecode(response.body)),
    );
  }

  static Future<List<CreditPaymentModel>> getPayments(int creditId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/credits/payments/$creditId'),
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception(_getError(response));
    }

    final Map<String, dynamic> data = Map<String, dynamic>.from(
      jsonDecode(response.body),
    );

    final List<dynamic> payments = data['pagos'] as List<dynamic>? ?? [];

    return payments
        .map(
          (item) =>
              CreditPaymentModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  static Future<void> cancelCredit(int creditId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/credits/cancel/$creditId'),
      headers: ApiConfig.adminHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception(_getError(response));
    }
  }

  static String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  static String? _nullableText(String? value) {
    if (value == null) {
      return null;
    }

    final text = value.trim();

    return text.isEmpty ? null : text;
  }

  static String _getError(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (data is Map && data['detail'] != null) {
        return data['detail'].toString();
      }
    } catch (_) {}

    return 'Error ${response.statusCode}: ${response.body}';
  }
}
