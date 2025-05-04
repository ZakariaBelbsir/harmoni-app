import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:harmoni/controllers/emotion_controller.dart';

import '../models/emotion.dart';

class EmotionStore extends ChangeNotifier {
  final List<Emotion> _emotions = [];

  get emotions => _emotions;

  void addEmotion(Emotion emotion) {
    EmotionController.addEmotion(emotion);
    _emotions.add(emotion);
    notifyListeners();
  }

  Future<void> getEmotions() async {
    if (_emotions.isEmpty) {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      final snpashot = await EmotionController.getEmotions(userId);
      for (var doc in snpashot.docs) {
        _emotions.add(doc.data());
      }
      notifyListeners();
    }
  }

  Future<Emotion?> getSingleEmotion(String id) async {
    // Check if _emotions has the emotion already
    final existingEmotion = _emotions.firstWhere((entry) => entry.id == id);
    if (existingEmotion != null) {
      return existingEmotion; // Return existing entry if found
    }

    // If not found locally, fetch from Firestore
    final snapshot = await EmotionController.getEmotion(id);
    if (snapshot.docs.isEmpty) {
      return null; // Handle case where no emotion is found in Firestore
    }
    final emotion = snapshot.docs.first.data();
    _emotions.add(emotion);
    notifyListeners();
    return emotion;
  }

  void removeEmotion(String journalEntryId) {
    _emotions.removeWhere((emotion) => emotion.journalEntryId == journalEntryId);
    notifyListeners();
  }
}
