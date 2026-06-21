import 'dart:convert';

import 'package:http/http.dart'
    as http;

class BudgetService {

  static const String baseUrl =
      "https://cash-control-3vhg.onrender.com";

  static Future<List<dynamic>>
      getBudgets(
    String email,
  ) async {

    final encodedEmail =
        Uri.encodeComponent(email);

    final response =
        await http.get(

      Uri.parse(
        "$baseUrl/budgets/$encodedEmail",
      ),
    );

    print(
      "GET BUDGETS STATUS: ${response.statusCode}",
    );

    print(
      "GET BUDGETS BODY: ${response.body}",
    );

    if (response.statusCode == 200) {

      final data =
          jsonDecode(response.body);

      if (data is List) {
        return data;
      }

      throw Exception(
        "Respuesta inesperada",
      );
    }

    throw Exception(
      "Error al cargar presupuestos: ${response.body}",
    );
  }

  static Future createBudget({

    required String email,

    required String category,

    required double monthlyLimit,

  }) async {

    final response =
        await http.post(

      Uri.parse(
        "$baseUrl/budgets/create",
      ),

      headers: {

        "Content-Type":
            "application/json",
      },

      body: jsonEncode({

        "user_email": email,

        "category": category,

        "monthly_limit": monthlyLimit,

        "current_spent": 0.0,
      }),
    );

    print(
      "CREATE BUDGET STATUS: ${response.statusCode}",
    );

    print(
      "CREATE BUDGET BODY: ${response.body}",
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {

      return jsonDecode(
        response.body,
      );
    }

    throw Exception(
      "Error al crear presupuesto: ${response.body}",
    );
  }

  static Future addSpent({

    required String budgetId,

    required double amount,

  }) async {

    final response =
        await http.put(

      Uri.parse(
        "$baseUrl/budgets/add-spent/$budgetId",
      ),

      headers: {

        "Content-Type":
            "application/json",
      },

      body: jsonEncode({

        "amount": amount,
      }),
    );

    print(
      "ADD SPENT STATUS: ${response.statusCode}",
    );

    print(
      "ADD SPENT BODY: ${response.body}",
    );

    if (response.statusCode == 200) {

      return jsonDecode(
        response.body,
      );
    }

    throw Exception(
      "Error al agregar gasto: ${response.body}",
    );
  }

  static Future deleteBudget(
    String budgetId,
  ) async {

    final response =
        await http.delete(

      Uri.parse(
        "$baseUrl/budgets/$budgetId",
      ),
    );

    print(
      "DELETE BUDGET STATUS: ${response.statusCode}",
    );

    print(
      "DELETE BUDGET BODY: ${response.body}",
    );

    if (response.statusCode == 200) {

      return jsonDecode(
        response.body,
      );
    }

    throw Exception(
      "Error al eliminar presupuesto: ${response.body}",
    );
  }
}