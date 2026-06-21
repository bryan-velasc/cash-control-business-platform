import 'dart:convert';
import 'package:http/http.dart' as http;

class GoalService {
  static const String baseUrl =
      "https://cash-control-3vhg.onrender.com";

  static Future<List<dynamic>> getGoals(String email) async {
    final encodedEmail = Uri.encodeComponent(email);

    final url = "$baseUrl/goals/$encodedEmail";

    final response = await http.get(
      Uri.parse(url),
    );

    print("URL GOALS: $url");
    print("GET GOALS STATUS: ${response.statusCode}");
    print("GET GOALS BODY: ${response.body}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded;
      } else {
        throw Exception("Respuesta inesperada: $decoded");
      }
    } else {
      throw Exception(
        "Error ${response.statusCode}: ${response.body}",
      );
    }
  }

  static Future createGoal(
    String email,
    String goalName,
    double targetAmount,
  ) async {
    final url = "$baseUrl/goals/create";

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "user_email": email,
        "goal_name": goalName,
        "target_amount": targetAmount,
        "current_amount": 0.0,
      }),
    );

    print("CREATE GOAL URL: $url");
    print("CREATE GOAL STATUS: ${response.statusCode}");
    print("CREATE GOAL BODY: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Error al crear meta ${response.statusCode}: ${response.body}",
      );
    }
  }

  static Future addSaving(
    String goalId,
    double amount,
  ) async {
    final url = "$baseUrl/goals/add-saving/$goalId";

    final response = await http.put(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "amount": amount,
      }),
    );

    print("ADD SAVING URL: $url");
    print("ADD SAVING STATUS: ${response.statusCode}");
    print("ADD SAVING BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Error al agregar ahorro ${response.statusCode}: ${response.body}",
      );
    }
  }

  static Future deleteGoal(String goalId) async {
    final url = "$baseUrl/goals/$goalId";

    final response = await http.delete(
      Uri.parse(url),
    );

    print("DELETE GOAL URL: $url");
    print("DELETE GOAL STATUS: ${response.statusCode}");
    print("DELETE GOAL BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Error al eliminar meta ${response.statusCode}: ${response.body}",
      );
    }
  }

  static Future<Map<String, dynamic>> getGoalsSummary(
    String email,
  ) async {
    final goals = await getGoals(email);

    double totalTarget = 0;
    double totalSaved = 0;

    for (var goal in goals) {
      totalTarget +=
          double.tryParse(goal["target_amount"].toString()) ?? 0;

      totalSaved +=
          double.tryParse(goal["current_amount"].toString()) ?? 0;
    }

    final double progress =
        totalTarget > 0 ? (totalSaved / totalTarget) * 100 : 0;

    return {
      "total_goals": goals.length,
      "total_target": totalTarget,
      "total_saved": totalSaved,
      "average_progress": progress,
    };
  }
}