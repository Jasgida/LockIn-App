import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  final String id;
  final String text;
  final DateTime date;
  final int minutes;

  JournalEntry({
    required this.id,
    required this.text,
    required this.date,
    required this.minutes,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'date': date.toIso8601String(),
        'minutes': minutes,
      };

  factory JournalEntry.fromMap(Map<String, dynamic> map) => JournalEntry(
        id: map['id'] ?? '',
        text: map['text'] ?? '',
        date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
        minutes: (map['minutes'] ?? 0) as int,
      );

  factory JournalEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JournalEntry(
      id: doc.id,
      text: data['text'] ?? '',
      date: DateTime.tryParse(data['date'] ?? '') ?? DateTime.now(),
      minutes: (data['minutes'] ?? 0) as int,
    );
  }
}
