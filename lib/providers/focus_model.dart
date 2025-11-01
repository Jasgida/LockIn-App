import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FocusModel extends ChangeNotifier {
  static const _prefs_streak_key = 'focus_streak';
  static const _prefs_date_key = 'focus_last_date';

  int _todayMinutes = 0;
  int get todayMinutes => _todayMinutes;

  int _streak = 0;
  int get streak => _streak;

  FocusModel() {
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final todayKey = _todayKeyForDate(DateTime.now());
    _todayMinutes = p.getInt(todayKey) ?? 0;
    _streak = p.getInt(_prefs_streak_key) ?? 0;
    notifyListeners();
  }

  String _dateString(DateTime d) => '${d.year}-${d.month}-${d.day}';
  String _todayKeyForDate(DateTime d) => 'focus_minutes_${_dateString(d)}';

  Future<void> addMinutes(int minutes) async {
    final p = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = _todayKeyForDate(today);
    final prev = p.getInt(todayKey) ?? 0;
    final updated = prev + minutes;
    await p.setInt(todayKey, updated);
    _todayMinutes = updated;

    final lastDateStr = p.getString(_prefs_date_key);
    if (lastDateStr == null) {
      _streak = 1;
    } else {
      final last = DateTime.tryParse(lastDateStr);
      if (last != null) {
        final yesterday = DateTime(today.year, today.month, today.day - 1);
        if (_dateString(last) == _dateString(yesterday)) {
          _streak = (p.getInt(_prefs_streak_key) ?? 0) + 1;
        } else if (_dateString(last) == _dateString(today)) {
          _streak = p.getInt(_prefs_streak_key) ?? 1;
        } else {
          _streak = 1;
        }
      } else {
        _streak = 1;
      }
    }
    await p.setInt(_prefs_streak_key, _streak);
    await p.setString(_prefs_date_key, today.toIso8601String());
    notifyListeners();
  }

  Future<void> refreshForDate(DateTime date) async {
    final p = await SharedPreferences.getInstance();
    final key = _todayKeyForDate(date);
    _todayMinutes = p.getInt(key) ?? 0;
    notifyListeners();
  }
}
