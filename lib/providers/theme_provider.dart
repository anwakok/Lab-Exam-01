import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  ThemeData getTheme() {
    if (_isDarkMode) {
      return ThemeData.dark(useMaterial3: true);
    } else {
      return ThemeData.light(useMaterial3: true);
    }
  }
}
