import 'dart:convert';

import 'package:http/http.dart' as http;

class NotificationService {
  static const String baseUrl =
      "https://cash-control-3vhg.onrender.com";

  static Future<List<dynamic>> getNotifications(
    String email,
  ) async {
    final encodedEmail = Uri.encodeComponent(email);

    final response = await http.get(
      Uri.parse("$baseUrl/notifications/$encodedEmail"),
    );

    print("GET NOTIFICATIONS STATUS: ${response.statusCode}");
    print("GET NOTIFICATIONS BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        return data;
      }

      throw Exception("Respuesta inesperada");
    }

    throw Exception(
      "Error al cargar notificaciones: ${response.body}",
    );
  }

  static Future<int> getUnreadCount(
    String email,
  ) async {
    final encodedEmail = Uri.encodeComponent(email);

    final response = await http.get(
      Uri.parse(
        "$baseUrl/notifications/unread-count/$encodedEmail",
      ),
    );

    print("UNREAD COUNT STATUS: ${response.statusCode}");
    print("UNREAD COUNT BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data["unread_count"] ?? 0;
    }

    return 0;
  }

  static Future markAsRead(
    String notificationId,
  ) async {
    final response = await http.put(
      Uri.parse(
        "$baseUrl/notifications/read/$notificationId",
      ),
    );

    print("MARK READ STATUS: ${response.statusCode}");
    print("MARK READ BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      "Error al marcar notificación: ${response.body}",
    );
  }

  static Future markAllAsRead(
    String email,
  ) async {
    final encodedEmail = Uri.encodeComponent(email);

    final response = await http.put(
      Uri.parse(
        "$baseUrl/notifications/read-all/$encodedEmail",
      ),
    );

    print("MARK ALL READ STATUS: ${response.statusCode}");
    print("MARK ALL READ BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      "Error al marcar todas como leídas: ${response.body}",
    );
  }

  static Future deleteNotification(
    String notificationId,
  ) async {
    final response = await http.delete(
      Uri.parse(
        "$baseUrl/notifications/$notificationId",
      ),
    );

    print("DELETE NOTIFICATION STATUS: ${response.statusCode}");
    print("DELETE NOTIFICATION BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      "Error al eliminar notificación: ${response.body}",
    );
  }
}