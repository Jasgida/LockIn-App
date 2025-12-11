// lib/providers/theme_model.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModel extends ChangeNotifier {
  static const String _darkModeKey = 'dark_mode';
  static const String _accentColorKey = 'accent_color';

  bool _isDark = false;
  Color _accent = const Color(0xFF00C853); // Default green

  bool get isDark => _isDark;
  Color get accent => _accent;

  ThemeModel() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool(_darkModeKey) ?? false;
    final savedColor = prefs.getInt(_accentColorKey);
    if (savedColor != null) _accent = Color(savedColor);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDark = !_isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, _isDark);
    notifyListeners();
  }

  Future<void> setAccentColor(Color color) async {
    _accent = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentColorKey, color.value);
    notifyListeners();
  }
}