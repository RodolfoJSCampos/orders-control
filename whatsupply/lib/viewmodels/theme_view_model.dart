import 'package:flutter/material.dart';

class ThemeViewModel extends ChangeNotifier {
  late bool _isDark;

  ThemeViewModel() {
    final platformBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    _isDark = platformBrightness == Brightness.dark;
  }

  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}
