// lib/providers/focus_model.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FocusModel extends ChangeNotifier {
  static const prefsStreakKey = 'focus_streak';
  static const prefsDateKey = 'focus_last_date';

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
    _streak = p.getInt(prefsStreakKey) ?? 0;
    notifyListeners();
  }

  String _dateString(DateTime d) => '${d.year}-${d.month}-${d.day}';
  String _todayKeyForDate(DateTime d) => 'focus_minutes_${_dateString(d)}';

  Future<void> addMinutes(int minutes) async {
    final p = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = _todayKeyForDate(today);
    final updated = (p.getInt(todayKey) ?? 0) + minutes;
    await p.setInt(todayKey, updated);
    _todayMinutes = updated;

    final lastDateStr = p.getString(prefsDateKey);
    final yesterday = DateTime(today.year, today.month, today.day - 1);

    if (lastDateStr == null) {
      _streak = 1;
    } else {
      final lastDate = DateTime.tryParse(lastDateStr);
      if (lastDate != null && _dateString(lastDate) == _dateString(yesterday)) {
        _streak = (p.getInt(prefsStreakKey) ?? 0) + 1;
      } else if (lastDate != null && _dateString(lastDate) == _dateString(today)) {
        // Same day
      } else {
        _streak = 1;
      }
    }

    await p.setInt(prefsStreakKey, _streak);
    await p.setString(prefsDateKey, today.toIso8601String());

    notifyListeners();
  }

  Future<void> refreshForDate(DateTime date) async {
    final p = await SharedPreferences.getInstance();
    final key = _todayKeyForDate(date);
    _todayMinutes = p.getInt(key) ?? 0;
    notifyListeners();
  }

  // START FOCUS SESSION — ACTIVATE BLOCKER
  void startFocusSession() {
    // Your logic to start focus
    // Example: start timer, add minutes, etc.
    notifyListeners();
  }

  // STOP FOCUS SESSION — DEACTIVATE BLOCKER
  void stopFocusSession() {
    // Your logic to stop focus
    // Example: stop timer, save minutes, etc.
    notifyListeners();
  }
}