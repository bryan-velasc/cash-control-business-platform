import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/api_message_model.dart';
import '../models/credit_model.dart';
import '../models/credit_payment_model.dart';
import 'api_config.dart';

class CreditService {
  static Future<List<CreditModel>> getCredits() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/credits/admin'),
      headers: ApiConfig.adminHeaders,
    );

    final data = _decodeResponse(response);

    if (data is List) {
      return data
          .map((item) => CreditModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    throw Exception('La API no devolvió una lista de fiados.');
  }

  static Future<CreditModel> createCredit(CreditModel credit) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/credits/create'),
      headers: ApiConfig.adminHeaders,
      body: jsonEncode(credit.toCreateJson()),
    );

    final data = _decodeResponse(response);

    return CreditModel.fromJson(Map<String, dynamic>.from(data));
  }

  static Future<CreditModel> getCreditById(int creditId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/credits/$creditId'),
      headers: ApiConfig.adminHeaders,
    );

    final data = _decodeResponse(response);

    return CreditModel.fromJson(Map<String, dynamic>.from(data));
  }

  static Future<List<CreditModel>> getCreditsByCustomer(int customerId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/credits/customer/$customerId'),
      headers: ApiConfig.adminHeaders,
    );

    final data = _decodeResponse(response);

    if (data is List) {
      return data
          .map((item) => CreditModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    throw Exception('La API no devolvió una lista de fiados del cliente.');
  }

  static Future<CreditModel> updateCredit({
    required int creditId,
    required Map<String, dynamic> data,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/credits/update/$creditId'),
      headers: ApiConfig.adminHeaders,
      body: jsonEncode(data),
    );

    final decoded = _decodeResponse(response);

    return CreditModel.fromJson(Map<String, dynamic>.from(decoded));
  }

  static Future<CreditModel> registerPayment({
    required int creditId,
    required CreditPaymentModel payment,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/credits/pay/$creditId'),
      headers: ApiConfig.adminHeaders,
      body: jsonEncode(payment.toCreateJson()),
    );

    final data = _decodeResponse(response);

    return CreditModel.fromJson(Map<String, dynamic>.from(data));
  }

  static Future<List<CreditPaymentModel>> getPaymentsByCredit(
    int creditId,
  ) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/credits/payments/$creditId'),
      headers: ApiConfig.adminHeaders,
    );

    final data = _decodeResponse(response);

    if (data is List) {
      return data
          .map(
            (item) =>
                CreditPaymentModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    if (data is Map && data['payments'] is List) {
      final payments = data['payments'] as List;

      return payments
          .map(
            (item) =>
                CreditPaymentModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    throw Exception('La API no devolvió una lista de abonos.');
  }

  static Future<ApiMessageModel> cancelCredit(int creditId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/credits/cancel/$creditId'),
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
}