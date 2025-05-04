import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:harmoni/models/journal_entry.dart';
import 'package:harmoni/services/journal_entry_store.dart';
import 'package:harmoni/shared/shared_title_style.dart';
import 'package:harmoni/shared/shared_button.dart';
import 'package:provider/provider.dart';

class SingleEntry extends StatefulWidget {
  const SingleEntry({super.key, required this.id});

  final String id;

  @override
  State<SingleEntry> createState() => _SingleEntryState();
}

class _SingleEntryState extends State<SingleEntry> {
  bool isEditing = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  JournalEntry? journalEntry;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEntry();
  }

  Future<void> _fetchEntry() async {
    final entry = await Provider.of<JournalEntryStore>(context, listen: false)
        .getSingleEntry(widget.id);

    setState(() {
      journalEntry = entry;
      if (entry != null) {
        _titleController.text = entry.title;
        _bodyController.text = entry.body;
      }
      isLoading = false;
    });
  }

  Future<void> _updateEntry() async {
    if (journalEntry != null) {
      final updatedEntry = JournalEntry(
        id: journalEntry!.id,
        title: _titleController.text,
        body: _bodyController.text,
        userId: journalEntry!.userId,
        date: DateTime.timestamp(),
      );

      await Provider.of<JournalEntryStore>(context, listen: false)
          .updateJournalEntry(updatedEntry);

      setState(() {
        journalEntry = updatedEntry;
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Entry updated successfully!")),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (journalEntry == null) {
      return const Scaffold(
        body: Center(child: Text("Entry not found")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).pop();
          },
        ),
        title: SharedTitleStyle('Entry'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Title"),
              style: Theme.of(context).textTheme.headlineMedium,
              enabled: isEditing,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(labelText: "Body"),
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: 5,
              enabled: isEditing,
            ),
            const SizedBox(height: 20),
            if (isEditing)
              SharedButton(
                onPressed: _updateEntry,
                backgroundColor: Colors.blue,
                child: const Text("Update"),
              ),
          ],
        ),
      ),
    );
  }
}
