import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:harmoni/controllers/journal_entry_controller.dart';
import 'package:harmoni/services/emotion_store.dart';

import '../models/journal_entry.dart';

class JournalEntryStore extends ChangeNotifier {
  final List<JournalEntry> _journalEntries = [];

  get journalEntries => _journalEntries;

  Future<String> addJournalEntry(JournalEntry journalEntry) async {
    final id = await JournalEntryController.addJournalEntry(journalEntry);
    final entryWithFirebaseId = JournalEntry(
        id: id,
        title: journalEntry.title,
        body: journalEntry.body,
        date: journalEntry.date,
        userId: journalEntry.userId);
    _journalEntries.add(entryWithFirebaseId);
    notifyListeners();

    return id;
  }

  void getJournalEntries() async {
    if (_journalEntries.isEmpty) {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      final snpashot = await JournalEntryController.getJournalEntries(userId);
      for (var doc in snpashot.docs) {
        _journalEntries.add(doc.data());
      }
      notifyListeners();
    }
  }

  Future<JournalEntry?> getSingleEntry(String id) async {
    // Check if _journalEntries has the entry already
    final existingEntry = _journalEntries.firstWhere((entry) => entry.id == id);
    if (existingEntry != null) {
      return existingEntry; // Return existing entry if found
    }

    // If not found locally, fetch from Firestore
    final snapshot = await JournalEntryController.getJournalEntry(id);
    if (snapshot.docs.isEmpty) {
      return null; // Handle case where no entry is found in Firestore
    }
    final journalEntry = snapshot.docs.first.data();
    _journalEntries.add(journalEntry);
    notifyListeners();
    return journalEntry;
  }

  Future<void> updateJournalEntry(JournalEntry journalEntry) async {
    await JournalEntryController.updateJournalEntry(journalEntry);

    // Update local store
    int index =
        _journalEntries.indexWhere((entry) => entry.id == journalEntry.id);
    if (index != -1) {
      _journalEntries[index] = journalEntry;
      notifyListeners();
    }
  }

  Future<void> deleteJournalEntry(JournalEntry journalEntry, EmotionStore emotionStore) async {
    final deletedId = await JournalEntryController.deleteJournalEntry(journalEntry.id);
    _journalEntries.removeWhere((entry) => entry.id == journalEntry.id);
    emotionStore.removeEmotion(deletedId);
    notifyListeners();
  }
}
