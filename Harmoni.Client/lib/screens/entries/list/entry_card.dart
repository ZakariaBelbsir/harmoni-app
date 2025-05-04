import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:harmoni/models/journal_entry.dart';
import 'package:harmoni/services/journal_entry_store.dart';
import 'package:harmoni/services/emotion_store.dart';
import 'package:harmoni/theme.dart';
import 'package:provider/provider.dart';

class Entrycard extends StatelessWidget {
  const Entrycard(this.journalEntry, {super.key});

  final JournalEntry journalEntry;

  void deleteEntry(context) {
    Provider.of<JournalEntryStore>(context, listen: false)
        .deleteJournalEntry(journalEntry, Provider.of<EmotionStore>(context, listen: false));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                journalEntry.title,
                style: TextStyle(color: AppColors.darkGray),
              ),
            ),
            IconButton(
              onPressed: () {
                GoRouter.of(context).push('/entry/${journalEntry.id}');
              },
              icon: Icon(Icons.arrow_forward),
              color: AppColors.darkGray,
            ),
            IconButton(
              onPressed: () {
                deleteEntry(context);
              },
              icon: Icon(Icons.delete),
              color: AppColors.error,
            ),
          ],
        ),
      ),
    );
  }
}
