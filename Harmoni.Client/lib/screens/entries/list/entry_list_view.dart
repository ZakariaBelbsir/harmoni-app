import 'package:flutter/material.dart';
import 'package:harmoni/screens/entries/list/entry_card.dart';
import 'package:harmoni/services/journal_entry_store.dart';
import 'package:harmoni/theme.dart';
import 'package:provider/provider.dart';

class EntryListView extends StatefulWidget {
  const EntryListView({super.key});

  @override
  State<EntryListView> createState() => _EntryListViewState();
}

class _EntryListViewState extends State<EntryListView> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.darkGray),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text(
              "Recent Entries",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child:
              Consumer<JournalEntryStore>(builder: (context, value, child) {
            if (value.journalEntries.isEmpty) {
              return Text(
                "No Entries Yet!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                ),
              );
            } else {
              return ListView.builder(
                itemCount: value.journalEntries.length,
                itemBuilder: (_, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Entrycard(value.journalEntries[index]),
                  );
                },
              );
            }
          })),
        ],
      ),
    ));
  }
}
