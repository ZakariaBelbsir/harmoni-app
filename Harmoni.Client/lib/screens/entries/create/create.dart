import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:harmoni/models/journal_entry.dart';
import 'package:harmoni/services/emotion_store.dart';
import 'package:harmoni/shared/shared_button.dart';
import 'package:harmoni/shared/shared_heading_style.dart';
import 'package:harmoni/shared/shared_title_style.dart';
import 'package:harmoni/theme.dart';
import 'package:provider/provider.dart';
import 'package:harmoni/services/journal_entry_store.dart';
import 'package:http/http.dart' as http;

import '../../../models/emotion.dart';

class CreateEntry extends StatefulWidget {
  const CreateEntry({super.key});

  @override
  State<CreateEntry> createState() => _CreateEntryState();
}

class _CreateEntryState extends State<CreateEntry> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String feedback = "";

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void saveEntry() async {
    if (_titleController.text.trim().isEmpty ||
        _bodyController.text.trim().isEmpty) {
      // Show an error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a title and body.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (FirebaseAuth.instance.currentUser?.uid != null) {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      JournalEntry journalEntry = JournalEntry(
          id: '',
          title: _titleController.text,
          body: _bodyController.text,
          date: DateTime.now(),
          userId: userId);
      final entryId =
          await Provider.of<JournalEntryStore>(context, listen: false)
              .addJournalEntry(journalEntry);

      Emotion? emotion =
          await predictEmotion(_bodyController.text, userId, entryId);
      if (emotion != null) {
        Provider.of<EmotionStore>(context, listen: false).addEmotion(emotion);
        GoRouter.of(context).push("/calendar");
      }
    } else {
      GoRouter.of(context).push("/login");
    }
  }

  Future<Emotion?> predictEmotion(
      String text, String? userId, String? journalEntryId) async {
    try {
      final response = await http.post(
        // change to current network IP Address
        Uri.parse('http://192.168.1.239:8000/predict_emotion'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'text': text,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        Emotion emotion = Emotion(
            id: '',
            name: data['emotion'],
            value: data['number'],
            date: DateTime.now(),
            userId: userId,
            journalEntryId: journalEntryId);
        return emotion;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).pop();
          },
        ),
        title: SharedTitleStyle('Add Journal Entry'),
        centerTitle: true,
      ),
      body: Container(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Icon(Icons.code, color: AppColors.mainColor),
                ),
                Center(
                  child: SharedHeadingStyle('Create New Entry'),
                ),
                const SizedBox(height: 30),
                TextField(
                    controller: _titleController,
                    obscureText: false,
                    decoration: InputDecoration(
                      labelText: "Title",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    )),
                const SizedBox(height: 20),
                TextField(
                    controller: _bodyController,
                    obscureText: false,
                    decoration: InputDecoration(
                      labelText: "Create Entry",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: 7),
                const SizedBox(height: 30),
                Center(
                  child: SharedButton(
                    onPressed: saveEntry,
                    backgroundColor: AppColors.mainColor,
                    child: Text('Save'),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
