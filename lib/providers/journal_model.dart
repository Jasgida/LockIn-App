import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../services/firebase_db_service.dart';

class JournalModel extends ChangeNotifier {
  final FirebaseDbService _db = FirebaseDbService();

  List<JournalEntry> _entries = [];
  List<JournalEntry> get entries => _entries;

  bool _loading = true;
  bool get loading => _loading;

  JournalModel() {
    _startRealTimeListener();
  }

  /// 🔥 Real-time listener (updates instantly)
  void _startRealTimeListener() {
    _loading = true;
    notifyListeners();

    _db.streamEntries().listen((data) {
      _entries = data;
      _loading = false;
      notifyListeners();
    });
  }

  /// Add or update an entry
  Future<void> addEntry(JournalEntry entry) async {
    await _db.saveJournal(entry);
  }

  /// Delete entry by ID
  Future<void> deleteEntry(String id) async {
    await _db.deleteEntry(id);
  }

  /// Optional: manual refresh
  Future<void> refresh() async {
    _loading = true;
    notifyListeners();

    _entries = await _db.fetchEntries();
    _loading = false;
    notifyListeners();
  }
}
