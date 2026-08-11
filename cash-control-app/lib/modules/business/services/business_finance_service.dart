import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/business_finance_model.dart';
import 'api_config.dart';

class BusinessFinanceService {
  // ==========================================================
  // RESUMEN FINANCIERO
  // ==========================================================

  static Future<BusinessFinanceModel> getSummary({
    String period = 'all',
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final query = _buildPeriodQuery(
      period: period,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/business-finance/summary',
    ).replace(queryParameters: query);

    final response = await http.get(uri, headers: ApiConfig.adminHeaders);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return BusinessFinanceModel.fromJson(Map<String, dynamic>.from(data));
    }

    throw Exception('Error ${response.statusCode}: ${response.body}');
  }

  // ==========================================================
  // TIMELINE
  // ==========================================================

  static Future<BusinessFinanceTimelineModel> getTimeline({
    String period = 'all',
    String groupBy = 'day',
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final query = _buildPeriodQuery(
      period: period,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );

    query['group_by'] = groupBy;

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/business-finance/timeline',
    ).replace(queryParameters: query);

    final response = await http.get(uri, headers: ApiConfig.adminHeaders);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return BusinessFinanceTimelineModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw Exception('Error ${response.statusCode}: ${response.body}');
  }

  // ==========================================================
  // TOP PRODUCTOS
  // ==========================================================

  static Future<BusinessTopProductsModel> getTopProducts({
    String period = 'all',
    int limit = 5,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final query = _buildPeriodQuery(
      period: period,
      dateFrom: dateFrom,
      dateTo: dateTo,
    );

    query['limit'] = limit.toString();

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/business-finance/top-products',
    ).replace(queryParameters: query);

    final response = await http.get(uri, headers: ApiConfig.adminHeaders);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return BusinessTopProductsModel.fromJson(Map<String, dynamic>.from(data));
    }

    throw Exception('Error ${response.statusCode}: ${response.body}');
  }

  // ==========================================================
  // QUERY DE PERIODOS
  // ==========================================================

  static Map<String, String> _buildPeriodQuery({
    required String period,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    final query = <String, String>{'period': period};

    if (period == 'custom') {
      if (dateFrom == null || dateTo == null) {
        throw Exception('Debes seleccionar fecha inicial y fecha final.');
      }

      query['date_from'] = dateFrom.toUtc().toIso8601String();

      query['date_to'] = dateTo.toUtc().toIso8601String();
    }

    return query;
  }
}
