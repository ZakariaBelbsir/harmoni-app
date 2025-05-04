import 'package:cloud_firestore/cloud_firestore.dart';

class Emotion {
  final String id;
  final String name;
  final int value;
  String? userId;
  final DateTime date;
  String? journalEntryId;

  Emotion(
      {required this.id,
      required this.name,
      required this.value,
      required this.date,
      required this.userId,
      required this.journalEntryId});

  factory Emotion.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data()!;
    Emotion emotion = Emotion(
        id: snapshot.id,
        name: data['name'],
        value: data['value'],
        date: DateTime.parse(data['date']),
        userId: data['userId'],
        journalEntryId: data['journalEntryId']);
    return emotion;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'value': value,
      'date': date.toIso8601String(),
      'userId': userId,
      'journalEntryId': journalEntryId
    };
  }
}
