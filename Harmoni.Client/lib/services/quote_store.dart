import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:harmoni/controllers/quote_controller.dart';
import 'package:harmoni/models/quote.dart';

class QuoteStore extends ChangeNotifier {
  final List<Quote> _favouriteQuotes = [];

  get quotes => _favouriteQuotes;

  void addQuote(Quote quote) {
    QuoteController.favouriteQuote(quote);

    _favouriteQuotes.add(quote);
    notifyListeners();
  }

  Future<void> getQuotes() async {
    if (_favouriteQuotes.isEmpty) {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      final snpashot = await QuoteController.getQuotes(userId);
      for (var doc in snpashot.docs) {
        _favouriteQuotes.add(doc.data());
      }
      notifyListeners();
    }
  }

  Future<void> deleteQuote(String? text) async {
    await QuoteController.deleteQuote(text);
    _favouriteQuotes.removeWhere((entry) => entry.text == text);
    notifyListeners();
  }
}
