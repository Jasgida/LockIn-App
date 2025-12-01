import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/journal_entry.dart';

class FirebaseDbService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  FirebaseDbService() {
    // Enable local persistence (works on mobile + web)
    try {
      _db.settings = const Settings(persistenceEnabled: true);
    } catch (_) {}
  }

  /// 🔐 Shortcut: get user ID safely
  String? get _uid => _auth.currentUser?.uid;

  /// Save or update a journal entry
  Future<void> saveJournal(JournalEntry entry) async {
    if (_uid == null) return;

    await _db
        .collection('users')
        .doc(_uid)
        .collection('journal')
        .doc(entry.id)
        .set(entry.toMap());
  }

  /// Fetch all journal entries (ordered newest first)
  Future<List<JournalEntry>> fetchEntries() async {
    if (_uid == null) return [];

    final snap = await _db
        .collection('users')
        .doc(_uid)
        .collection('journal')
        .orderBy('date', descending: true)
        .get();

    return snap.docs
        .map((d) =>
            JournalEntry.fromMap(Map<String, dynamic>.from(d.data())))
        .toList(growable: false);
  }

  /// Real-time listener for live updating journal UI
  Stream<List<JournalEntry>> streamEntries() {
    if (_uid == null) return const Stream.empty();

    return _db
        .collection('users')
        .doc(_uid)
        .collection('journal')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) =>
                  JournalEntry.fromMap(Map<String, dynamic>.from(d.data())))
              .toList(growable: false),
        );
  }

  /// Delete journal entry
  Future<void> deleteEntry(String id) async {
    if (_uid == null) return;

    await _db
        .collection('users')
        .doc(_uid)
        .collection('journal')
        .doc(id)
        .delete();
  }
}
