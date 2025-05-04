import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:harmoni/services/emotion_store.dart';
import 'package:harmoni/services/quote_store.dart';
import 'package:harmoni/theme.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../models/quote.dart';

var uuid = const Uuid();

class DailyQuote extends StatefulWidget {
  const DailyQuote({super.key});

  @override
  State<DailyQuote> createState() => _DailyQuoteState();
}

class _DailyQuoteState extends State<DailyQuote> {
  String? _dailyQuote;
  bool _isLoading = false;
  bool _isFavourited = false;
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    fetchQuote();
  }

  Future<void> fetchQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final lastFetched = prefs.getString('lastFetchedDate');
    final cachedQuote = prefs.getString('dailyQuote');
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Use cached quote if available and date matches today
    if (lastFetched == today) {
      setState(() {
        _dailyQuote = cachedQuote;
      });
      checkIfFavourited();
      return;
    }

    // Fetch new quote
    setState(() {
      _isLoading = true;
    });

    final quote = await fetchUserCustomQuote();

    if (quote != null) {
      // Cache the new quote
      await prefs.setString('lastFetchedDate', today);
      await prefs.setString('dailyQuote', quote);
    }

    setState(() {
      _dailyQuote = quote;
      _isLoading = false;
    });
  }

  Future<void> checkIfFavourited() async {
    if (_dailyQuote == null) return;
    if (_userId == null) {
      setState(() {
        _isFavourited = false;
      });
      return;
    }

    final quoteStore = Provider.of<QuoteStore>(context, listen: false);
    await quoteStore.getQuotes();

    final isFavourited = quoteStore.quotes
        .any((quote) => quote.text == _dailyQuote && quote.userId == _userId);

    setState(() {
      _isFavourited = isFavourited;
    });
  }

  Future<String?> fetchUserCustomQuote() async {
    const apiKey = 'AIzaSyCR1-M2rE8VNr667RuR6VI4sY9GVZipNok';
    final model = GenerativeModel(
        model: 'gemini-2.0-flash-exp',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
            temperature: 1,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 256,
            responseMimeType: 'text/plain'));

    try {
      final emotionStore = Provider.of<EmotionStore>(context, listen: false);
      await emotionStore.getEmotions();

      // Get last 10 emotions
      final lastEmotions = emotionStore.emotions.reversed.take(10).toList();

      // Format the last emotions into a readable string
      final emotionContext = lastEmotions.isNotEmpty
          ? "considering the user's recent feelings which include: ${lastEmotions.map((e) => e.name).join(', ')}"
          : '';

      const basePrompt =
          'Generate a unique single quote for today. Do not include anything other than the quote';
      final prompt = emotionContext + basePrompt;

      final chat = model.startChat(history: [
        Content.multi([TextPart(prompt)])
      ]);
      final response = await chat.sendMessage(Content.text(prompt));

      return response.text?.trim();
    } catch (error) {
      return null;
    }
  }

  void toggleFavouriteQuote() {
    if (_userId != null) {
      if (!_isFavourited) {
        Quote quote = Quote(id: '', text: _dailyQuote, userId: _userId);
        Provider.of<QuoteStore>(context, listen: false).addQuote(quote);
        setState(() {
          _isFavourited = true;
        });
      } else {
        Provider.of<QuoteStore>(context, listen: false)
            .deleteQuote(_dailyQuote);
        setState(() {
          _isFavourited = false;
        });
      }
    } else {
      GoRouter.of(context).push('login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        color: AppColors.offWhite,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _dailyQuote != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Daily Quote',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGray),
                      ),
                      const SizedBox(height: 8),
                      IconButton(
                          onPressed: toggleFavouriteQuote,
                          icon: _isFavourited
                              ? Icon(Icons.star, color: Colors.amber)
                              : Icon(Icons.star_border, color: Colors.amber)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                              child: Text(
                            _dailyQuote!,
                            style: TextStyle(
                                fontSize: 16, color: AppColors.darkGray),
                            textAlign: TextAlign.center,
                          ))
                        ],
                      )
                    ],
                  )
                : const Center(
                    child: Text(
                    'No quote available today.',
                    style: TextStyle(color: Colors.grey),
                  )));
  }
}
