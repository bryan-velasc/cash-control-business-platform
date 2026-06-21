import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/api_message_model.dart';
import '../models/customer_model.dart';
import '../models/customer_summary_model.dart';
import 'api_config.dart';

class CustomerService {
  static Future<List<CustomerModel>> getCustomers() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/customers/admin'),
      headers: ApiConfig.adminHeaders,
    );

    final data = _decodeResponse(response);

    if (data is List) {
      return data
          .map((item) => CustomerModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    throw Exception('La API no devolvió una lista de clientes.');
  }

  static Future<CustomerModel> createCustomer(CustomerModel customer) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/customers/create'),
      headers: ApiConfig.adminHeaders,
      body: jsonEncode(customer.toCreateJson()),
    );

    final data = _decodeResponse(response);

    return CustomerModel.fromJson(Map<String, dynamic>.from(data));
  }

  static Future<CustomerModel> getCustomerById(int customerId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/customers/$customerId'),
      headers: ApiConfig.adminHeaders,
    );

    final data = _decodeResponse(response);

    return CustomerModel.fromJson(Map<String, dynamic>.from(data));
  }

  static Future<CustomerSummaryModel> getCustomerSummary(int customerId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/customers/$customerId/summary'),
      headers: ApiConfig.adminHeaders,
    );

    final data = _decodeResponse(response);

    return CustomerSummaryModel.fromJson(Map<String, dynamic>.from(data));
  }

  static Future<CustomerModel> updateCustomer({
    required int customerId,
    required Map<String, dynamic> data,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/customers/update/$customerId'),
      headers: ApiConfig.adminHeaders,
      body: jsonEncode(data),
    );

    final decoded = _decodeResponse(response);

    return CustomerModel.fromJson(Map<String, dynamic>.from(decoded));
  }

  static Future<ApiMessageModel> deleteCustomer(int customerId) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/customers/delete/$customerId'),
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