import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { system, light, dark }

class ThemeProvider extends ChangeNotifier {
  static const _themeKey = 'app_theme_mode';

  AppThemeMode _appThemeMode = AppThemeMode.system;

  AppThemeMode get appThemeMode => _appThemeMode;

  bool get isDark => _appThemeMode == AppThemeMode.dark;

  ThemeMode get themeMode {
    switch (_appThemeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themeKey);
    if (saved != null) {
      _appThemeMode = AppThemeMode.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => AppThemeMode.dark,
      );
    }
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _appThemeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  Future<void> toggleTheme(bool value) async {
    await setThemeMode(value ? AppThemeMode.dark : AppThemeMode.light);
  }
}