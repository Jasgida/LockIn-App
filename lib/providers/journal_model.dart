import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/journal_entry.dart';
import '../services/firebase_db.dart';

class JournalModel extends ChangeNotifier {
  static const _prefsKey = 'lockin_journal_entries';
  final List<JournalEntry> _items = [];
  final FirebaseDbService _firebase = FirebaseDbService();

  List<JournalEntry> get items => List.unmodifiable(_items);

  JournalModel() {
    _load();
  }

  Future<void> _load() async {
    // try local persistence
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List;
        _items.addAll(list.map((e) => JournalEntry.fromMap(Map<String, dynamic>.from(e))));
      }
    } catch (_) {}

    // try cloud merge
    try {
      final cloud = await _firebase.fetchEntries();
      for (final e in cloud) {
        if (!_items.any((i) => i.id == e.id)) _items.add(e);
      }
      _items.sort((a, b) => b.date.compareTo(a.date));
      await _save();
      notifyListeners();
    } catch (e) {
      debugPrint('Firestore sync error: $e');
    }
  }

  Future<void> add(JournalEntry e) async {
    _items.insert(0, e);
    notifyListeners();
    await _save();
    try {
      await _firebase.saveJournal(e);
    } catch (err) {
      debugPrint('Cloud save failed: $err');
    }
  }

  Future<void> remove(String id) async {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
    await _save();
    try {
      await _firebase.deleteEntry(id);
    } catch (err) {
      debugPrint('Cloud delete failed: $err');
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_items.map((e) => e.toMap()).toList()));
  }
}
