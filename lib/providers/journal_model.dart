import 'package:flutter/material.dart';
import '../services/firebase_db_service.dart';
import '../models/journal_entry.dart';

class JournalModel extends ChangeNotifier {
  final FirebaseDbService _db = FirebaseDbService();

  List<JournalEntry> _entries = [];
  List<JournalEntry> get items => _entries;        // ← this is what JournalScreen uses
  List<JournalEntry> get entries => _entries;

  bool _loading = true;
  bool get loading => _loading;

  JournalModel() {
    _startRealTimeListener();
  }

  void _startRealTimeListener() {
    _loading = true;
    notifyListeners();

    _db.streamEntries().listen((data) {
      _entries = data;
      _loading = false;
      notifyListeners();
    });
  }

  // These are the exact methods JournalScreen calls
  Future<void> add(JournalEntry entry) async => await _db.saveJournal(entry);
  Future<void> remove(String id) async => await _db.deleteEntry(id);

  // Keep your original methods too (for other parts of the app)
  Future<void> addEntry(JournalEntry entry) async => await add(entry);
  Future<void> deleteEntry(String id) async => await remove(id);

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    _entries = await _db.fetchEntries();
    _loading = false;
    notifyListeners();
  }
}