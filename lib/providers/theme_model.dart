import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModel extends ChangeNotifier {
  Color _accent = const Color(0xFF2FB3A6);
  Color get accent => _accent;
  static const _prefsKey = 'lockin_theme_color';

  ThemeModel() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getInt(_prefsKey);
    if (v != null) {
      _accent = Color(v);
      notifyListeners();
    }
  }

  Future<void> setAccent(Color c) async {
    _accent = c;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setInt(_prefsKey, c.value);
  }
}
