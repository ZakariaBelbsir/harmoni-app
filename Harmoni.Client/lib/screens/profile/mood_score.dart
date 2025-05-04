import 'package:flutter/material.dart';
import 'package:harmoni/services/emotion_store.dart';
import 'package:harmoni/theme.dart';
import 'package:provider/provider.dart';

class MoodScore extends StatefulWidget {
  const MoodScore({super.key});

  @override
  State<MoodScore> createState() => _MoodScoreState();
}

class _MoodScoreState extends State<MoodScore> {

  double _getEmotionValue(String emotionName) {
    switch (emotionName.toLowerCase()) {
      case 'joy':
        return 3.0;
      case 'love':
        return 4.0;
      case 'surprise':
        return 5.0;
      case 'sadness':
        return 2.0;
      case 'anger':
        return 1.0;
      case 'fear':
        return 0.0;
      default:
        return 2.5;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EmotionStore>(
      builder: (context, emotionStore, child) {
        if (emotionStore.emotions.isEmpty) {
          return const Center(child: Text('No emotion data available'));
        }

        // Calculate the average emotion value.
        double averageScore = 0;
        for (var emotion in emotionStore.emotions) {
          averageScore += _getEmotionValue(emotion.name);
        }
        averageScore = averageScore / emotionStore.emotions.length;

        // Scale the average score to a 0-100 scale.
        final double scaledScore = (averageScore / 5.0) * 100;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.offWhite),
          ),
          child: Column(
            children: [
              Text(
                'Average Mood Score',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center( // Center the text within the Expanded
                  child: Text(
                    '${scaledScore.toStringAsFixed(2)}%', // Display the scaled average with 2 decimal places
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), //Style the average
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
