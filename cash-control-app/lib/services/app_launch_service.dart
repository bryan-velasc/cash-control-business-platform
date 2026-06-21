import 'package:flutter/services.dart';

class AppLaunchService {
  static const MethodChannel _channel =
      MethodChannel(
    "cash_control/launch",
  );

  static Future<String> getInitialRoute() async {
    try {
      final route =
          await _channel.invokeMethod<String>(
        "getInitialRoute",
      );

      if (route == null ||
          route.trim().isEmpty) {
        return "/";
      }

      return route;
    } catch (e) {
      return "/";
    }
  }
}