import 'package:cloud_firestore/cloud_firestore.dart';

class Quote {
  String id;
  final String? text;
  String? userId;

  Quote({required this.id, required this.text, required this.userId});

  factory Quote.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data()!;
    Quote quote = Quote(
      id: snapshot.id,
      text: data['text'],
      userId: data['userId'],
    );
    return quote;
  }

  Map<String, dynamic> toFirestore() {
    return {'text': text, 'userId': userId};
  }
}
