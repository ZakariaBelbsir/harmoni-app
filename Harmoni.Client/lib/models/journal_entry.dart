import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  final String id;
  String title;
  String body;
  String? userId;
  final DateTime date;

  JournalEntry(
      {required this.id,
      required this.title,
      required this.body,
      required this.date,
      required this.userId});

  factory JournalEntry.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data()!;
    JournalEntry journalEntry = JournalEntry(
        id: snapshot.id,
        title: data['title'],
        body: data['body'],
        date: DateTime.parse(data['date']),
        userId: data['userId']);
    return journalEntry;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      'date': date.toIso8601String(),
      'userId': userId
    };
  }
}
