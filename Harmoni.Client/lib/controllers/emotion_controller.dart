import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harmoni/models/emotion.dart';

class EmotionController {
  static final ref = FirebaseFirestore.instance
      .collection('emotions')
      .withConverter(
          fromFirestore: Emotion.fromFirestore,
          toFirestore: (Emotion emotion, _) => emotion.toFirestore());

  // add journal emotion
  static Future<void> addEmotion(Emotion emotion) async {
    await ref.add(emotion);
  }

  // fetch emotions
  static Future<QuerySnapshot<Emotion>> getEmotions(String? userId) async {
    return ref.where('userId', isEqualTo: userId).get();
  }

  // get single emotion
  static Future<QuerySnapshot<Emotion>> getEmotion(String id) async {
    return ref.where('id' == id).get();
  }
}
