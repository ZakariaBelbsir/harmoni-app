import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:harmoni/models/quote.dart';
import 'package:harmoni/services/quote_store.dart';
import 'package:harmoni/theme.dart';
import 'package:provider/provider.dart';

class FavouriteQuotes extends StatefulWidget {
  const FavouriteQuotes({super.key});

  @override
  State<FavouriteQuotes> createState() => _FavouriteQuotesState();
}

class _FavouriteQuotesState extends State<FavouriteQuotes> {
  @override
  void initState() {
    super.initState();
    // Fetch quotes when the widget initializes
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      Provider.of<QuoteStore>(context, listen: false).getQuotes();
    }
  }

  void _showDeleteConfirmation(Quote quote) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Quote'),
          content: Text(
              'Are you sure you want to delete this quote?\n\n"${quote.text}"'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<QuoteStore>(context, listen: false)
                    .deleteQuote(quote.text);
                Navigator.pop(context, 'Delete');
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favourite Quotes"),
      ),
      body: Consumer<QuoteStore>(
        builder: (context, quoteStore, child) {
          final quotes = quoteStore.quotes;

          if (quotes.isEmpty) {
            return const Center(
              child: Text("No favourite quotes yet!"),
            );
          }

          return ListView.builder(
            itemCount: quotes.length,
            itemBuilder: (context, index) {
              final quote = quotes[index];
              return Dismissible(
                key: Key(quote.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  quoteStore.deleteQuote(quote.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deleted "${quote.text}"')),
                  );
                },
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirm'),
                      content: const Text(
                          'Are you sure you want to delete this quote?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Delete',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                child: Card(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            quote.text ?? '',
                            style: TextStyle(color: AppColors.darkGray),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showDeleteConfirmation(quote),
                          icon: const Icon(Icons.star, color: Colors.amber),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
