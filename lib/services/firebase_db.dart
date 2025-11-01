import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/journal_entry.dart';

class FirebaseDbService {
  final _db = FirebaseFirestore.instance;

  FirebaseDbService() {
    // enable persistence (should be fine on mobile/web)
    try {
      _db.settings = const Settings(persistenceEnabled: true);
    } catch (_) {}
  }

  Future<void> saveJournal(JournalEntry entry) async {
    // Use doc id to keep same id in firestore
    await _db.collection('journal').doc(entry.id).set(entry.toMap());
  }

  Future<List<JournalEntry>> fetchEntries() async {
    final snap = await _db.collection('journal').orderBy('date', descending: true).get();
    return snap.docs.map((d) => JournalEntry.fromMap(Map<String, dynamic>.from(d.data()))).toList(growable: false);
  }

  Future<void> deleteEntry(String id) async {
    await _db.collection('journal').doc(id).delete();
  }
}
