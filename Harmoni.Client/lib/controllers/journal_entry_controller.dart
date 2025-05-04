import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harmoni/models/journal_entry.dart';

class JournalEntryController {
  static final ref = FirebaseFirestore.instance
      .collection('journalEntries')
      .withConverter(
          fromFirestore: JournalEntry.fromFirestore,
          toFirestore: (JournalEntry journalEntry, _) =>
              journalEntry.toFirestore());

  // add journal entry
  static Future<String> addJournalEntry(JournalEntry journalEntry) async {
    final docRef = await ref.add(journalEntry);
    return docRef.id;
  }

  // fetch entries
  static Future<QuerySnapshot<JournalEntry>> getJournalEntries(
      String? userId) async {
    return ref.where('userId', isEqualTo: userId).get();
  }

  // update entries
  static Future<void> updateJournalEntry(JournalEntry journalEntry) async {
    await ref
        .doc(journalEntry.id)
        .update({'title': journalEntry.title, 'body': journalEntry.body});
  }

  // get single entry
  static Future<QuerySnapshot<JournalEntry>> getJournalEntry(String id) async {
    return ref.where('id' == id).get();
  }

  static Future<String> deleteJournalEntry(String id) async {
    final db = FirebaseFirestore.instance;

    // Get all emotions related to a journal entry
    final emotionQuery = await db
        .collection('emotions')
        .where('journalEntryId', isEqualTo: id)
        .get();
    for (final doc in emotionQuery.docs) {
      // cascade delete emotions when deleting entry
      await doc.reference.delete();
    }
    await ref.doc(id).delete();
    return id;
  }
}
