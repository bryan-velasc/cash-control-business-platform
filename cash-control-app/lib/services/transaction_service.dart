import 'dart:convert';

import 'package:http/http.dart' as http;

import 'offline_sync_service.dart';

import 'local_database_service.dart';

class TransactionService {
  static const String baseUrl =
      "https://cash-control-3vhg.onrender.com";

  static Future<Map<String, dynamic>> createTransaction({
    required String email,
    required String type,
    required String category,
    required double amount,
    required String description,
    String note = "",
    String sourceMode = "general",
    String? sourceTransactionId,
    String? sourceTransactionName,
  }) async {
    final online =
        await OfflineSyncService.hasInternet();

    if (!online) {
      await OfflineSyncService.savePendingTransaction(
        email: email,
        type: type,
        category: category,
        amount: amount,
        description: description,
        note: note,
        sourceMode: sourceMode,
        sourceTransactionId: sourceTransactionId,
        sourceTransactionName: sourceTransactionName,
      );

      return {
        "message": "Movimiento guardado offline",
        "offline": true,
        "balance": 0,
      };
    }

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/transactions/create"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "user_email": email,
          "type": type,
          "category": category,
          "amount": amount,
          "description": description,
          "note": note,
          "source_mode": sourceMode,
          "source_transaction_id": sourceTransactionId,
          "source_transaction_name": sourceTransactionName,
        }),
      );

      print("CREATE TRANSACTION STATUS: ${response.statusCode}");
      print("CREATE TRANSACTION BODY: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      }

      throw Exception(
        data["detail"]?.toString() ??
            "Error al crear movimiento",
      );
    } catch (e) {
      await OfflineSyncService.savePendingTransaction(
        email: email,
        type: type,
        category: category,
        amount: amount,
        description: description,
        note: note,
        sourceMode: sourceMode,
        sourceTransactionId: sourceTransactionId,
        sourceTransactionName: sourceTransactionName,
      );

      return {
        "message":
            "Sin conexión estable. Movimiento guardado offline",
        "offline": true,
        "balance": 0,
      };
    }
  }

  static Future<List<dynamic>> getTransactions(
    String email,
  ) async {
    final encodedEmail = Uri.encodeComponent(email);

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/transactions/$encodedEmail"),
      );

      print("GET TRANSACTIONS STATUS: ${response.statusCode}");
      print("GET TRANSACTIONS BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          await LocalDatabaseService.saveData(
            key: "cached_transactions_$email",
            value: data,
          );

          return data;
        }

        return [];
      }

      throw Exception();
    } catch (e) {
      final cached = LocalDatabaseService.getData(
        "cached_transactions_$email",
      );

      if (cached != null) {
        return List<dynamic>.from(cached);
      }

      throw Exception(
        "Error al cargar movimientos offline",
      );
    }
  }

  static Future<Map<String, dynamic>> getBalance(
    String email,
  ) async {
    final encodedEmail = Uri.encodeComponent(email);

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/balance/$encodedEmail"),
      );

      print("GET BALANCE STATUS: ${response.statusCode}");
      print("GET BALANCE BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        await LocalDatabaseService.saveData(
          key: "cached_balance_$email",
          value: data,
        );

        return Map<String, dynamic>.from(data);
      }

      throw Exception();
    } catch (e) {
      final cached = LocalDatabaseService.getData(
        "cached_balance_$email",
      );

      if (cached != null) {
        return Map<String, dynamic>.from(cached);
      }

      throw Exception(
        "Error al cargar balance offline",
      );
    }
  }

  static Future<List<dynamic>> getFinancialAdvice(
    String email,
  ) async {
    final encodedEmail = Uri.encodeComponent(email);

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/financial-advice/$encodedEmail"),
      );

      print("FINANCIAL ADVICE STATUS: ${response.statusCode}");
      print("FINANCIAL ADVICE BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final advice = data["advice"] ?? [];

        await LocalDatabaseService.saveData(
          key: "cached_financial_advice_$email",
          value: advice,
        );

        return List<dynamic>.from(advice);
      }

      throw Exception();
    } catch (e) {
      final cached = LocalDatabaseService.getData(
        "cached_financial_advice_$email",
      );

      if (cached != null) {
        return List<dynamic>.from(cached);
      }

      return [];
    }
  }

  static Future<List<dynamic>> getIncomeSources(
    String email,
  ) async {
    final encodedEmail = Uri.encodeComponent(email);

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/transactions/income-sources/$encodedEmail"),
      );

      print("INCOME SOURCES STATUS: ${response.statusCode}");
      print("INCOME SOURCES BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          await LocalDatabaseService.saveData(
            key: "cached_income_sources_$email",
            value: data,
          );

          return data;
        }

        return [];
      }

      throw Exception();
    } catch (e) {
      final cached = LocalDatabaseService.getData(
        "cached_income_sources_$email",
      );

      if (cached != null) {
        return List<dynamic>.from(cached);
      }

      return [];
    }
  }

  static Future<Map<String, dynamic>> getChartSummary(
    String email,
  ) async {
    final encodedEmail = Uri.encodeComponent(email);

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/transactions/chart-summary/$encodedEmail"),
      );

      print("CHART SUMMARY STATUS: ${response.statusCode}");
      print("CHART SUMMARY BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        await LocalDatabaseService.saveData(
          key: "cached_chart_summary_$email",
          value: data,
        );

        return Map<String, dynamic>.from(data);
      }

      throw Exception();
    } catch (e) {
      final cached = LocalDatabaseService.getData(
        "cached_chart_summary_$email",
      );

      if (cached != null) {
        return Map<String, dynamic>.from(cached);
      }

      throw Exception(
        "Error al cargar resumen de gráficas offline",
      );
    }
  }

  static Future<Map<String, dynamic>> getIncomeDetail(
    String incomeId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/transactions/income-detail/$incomeId"),
      );

      print("INCOME DETAIL STATUS: ${response.statusCode}");
      print("INCOME DETAIL BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        await LocalDatabaseService.saveData(
          key: "cached_income_detail_$incomeId",
          value: data,
        );

        return Map<String, dynamic>.from(data);
      }

      throw Exception();
    } catch (e) {
      final cached = LocalDatabaseService.getData(
        "cached_income_detail_$incomeId",
      );

      if (cached != null) {
        return Map<String, dynamic>.from(cached);
      }

      throw Exception(
        "Error al cargar detalle del ingreso offline",
      );
    }
  }

  static Future<Map<String, dynamic>> getMoneyFlow(
    String email,
  ) async {
    final encodedEmail = Uri.encodeComponent(email);

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/transactions/money-flow/$encodedEmail"),
      );

      print("MONEY FLOW STATUS: ${response.statusCode}");
      print("MONEY FLOW BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        await LocalDatabaseService.saveData(
          key: "cached_money_flow_$email",
          value: data,
        );

        return Map<String, dynamic>.from(data);
      }

      throw Exception();
    } catch (e) {
      final cached = LocalDatabaseService.getData(
        "cached_money_flow_$email",
      );

      if (cached != null) {
        return Map<String, dynamic>.from(cached);
      }

      throw Exception(
        "Error al cargar flujo de dinero offline",
      );
    }
  }

  static Future<List<dynamic>> getTimeline(
    String email,
  ) async {
    final encodedEmail = Uri.encodeComponent(email);

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/transactions/timeline/$encodedEmail"),
      );

      print("TIMELINE STATUS: ${response.statusCode}");
      print("TIMELINE BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final timeline = data["timeline"] ?? [];

        await LocalDatabaseService.saveData(
          key: "cached_timeline_$email",
          value: timeline,
        );

        return List<dynamic>.from(timeline);
      }

      throw Exception();
    } catch (e) {
      final cached = LocalDatabaseService.getData(
        "cached_timeline_$email",
      );

      if (cached != null) {
        return List<dynamic>.from(cached);
      }

      return [];
    }
  }
}