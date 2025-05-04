import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:harmoni/models/quote.dart';

class QuoteController {
  static final ref = FirebaseFirestore.instance
      .collection('favouriteQuotes')
      .withConverter(
      fromFirestore: Quote.fromFirestore,
      toFirestore: (Quote quote, _) =>
          quote.toFirestore());

  // add quote to favourites
  static Future<void> favouriteQuote(Quote quote) async {
    await ref.add(quote);
  }

  // fetch quotes
  static Future<QuerySnapshot<Quote>> getQuotes(
      String? userId) async {
    return ref.where('userId', isEqualTo: userId).get();
  }

  // delete quote
  static Future<void> deleteQuote(String? text) async {
    // add validation
    QuerySnapshot querySnapshot =  await ref.where('text', isEqualTo: text).get();
    querySnapshot.docs.first.reference.delete();
  }
}
