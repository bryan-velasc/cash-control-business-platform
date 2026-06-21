import 'package:flutter/material.dart';

class ThemeProvider
    extends ChangeNotifier {

  ThemeMode _themeMode =
      ThemeMode.dark;

  ThemeMode get themeMode =>
      _themeMode;

  void toggleTheme() {

    if (_themeMode ==
        ThemeMode.dark) {

      _themeMode =
          ThemeMode.light;

    } else {

      _themeMode =
          ThemeMode.dark;
    }

    notifyListeners();
  }
}