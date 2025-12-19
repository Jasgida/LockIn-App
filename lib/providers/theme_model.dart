// lib/providers/theme_model.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModel extends ChangeNotifier {
  bool _isDark = false;
  Color _accent = Colors.orange;

  bool get isDark => _isDark;
  Color get accent => _accent;

  ThemeModel() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final p = await SharedPreferences.getInstance();
    _isDark = p.getBool('isDark') ?? false;
    final accentIndex = p.getInt('accentIndex') ?? 0;
    _accent = _accentColors[accentIndex];
    notifyListeners();
  }

  final List<Color> _accentColors = [
    Colors.orange,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.red,
    Colors.teal,
  ];

  void toggleDarkMode() async {
    _isDark = !_isDark;
    final p = await SharedPreferences.getInstance();
    await p.setBool('isDark', _isDark);
    notifyListeners();
  }

  void setAccentColor(Color color) async {
    _accent = color;
    final index = _accentColors.indexOf(color);
    final p = await SharedPreferences.getInstance();
    await p.setInt('accentIndex', index);
    notifyListeners();
  }
}