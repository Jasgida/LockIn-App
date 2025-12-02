import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModel extends ChangeNotifier {
  Color _accent = const Color(0xFF2FB3A6);
  bool _isDark = false;

  Color get accent => _accent;
  bool get isDark => _isDark;

  static const _prefsKey = 'lockin_theme_color';
  static const _darkKey = 'lockin_dark_mode';

  ThemeModel() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getInt(_prefsKey);
    if (v != null) _accent = Color(v);

    _isDark = p.getBool(_darkKey) ?? false;
    notifyListeners();
  }

  Future<void> setAccent(Color c) async {
    _accent = c;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setInt(_prefsKey, c.value);
  }

  Future<void> setDarkMode(bool value) async {
    _isDark = value;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setBool(_darkKey, value);
  }
}