import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:harmoni/screens/home/daily_quote.dart';
import 'package:harmoni/screens/entries/list/entry_list_view.dart';
import 'package:harmoni/services/journal_entry_store.dart';
import 'package:harmoni/shared/shared_title_style.dart';
import 'package:harmoni/theme.dart';
import 'package:provider/provider.dart';
import 'package:harmoni/services/user_store.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    // Fetch journal entries
    Provider.of<JournalEntryStore>(context, listen: false).getJournalEntries();

    // Fetch user data
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      Provider.of<UserStore>(context, listen: false)
          .fetchUser(firebaseUser.uid);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SharedTitleStyle("Home"),
        centerTitle: true,
        backgroundColor: AppColors.mainColor,
        foregroundColor: AppColors.offWhite,
      ),
      body: Consumer<UserStore>(
        builder: (context, userStore, child) {
          if (userStore.isFetching || userStore.authUser == null && FirebaseAuth.instance.currentUser != null) {
            return const Center(child: CircularProgressIndicator());
          } else if (userStore.authUser != null) {
            final currentUser = userStore.authUser!;
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Display profile picture
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: currentUser.profilePicturePath != null
                                  ? FileImage(File(currentUser.profilePicturePath!))
                                  : AssetImage("assets/img/user/userpic.jpg")
                              as ImageProvider,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.offWhite,
                                ),
                                child: Text(
                                  'Hi, ${currentUser.username}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ),
                            TextButton(
                              child: Text('Add Entry'),
                              onPressed: () {
                                GoRouter.of(context).push('/create-entry');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Daily Quote
                  DailyQuote(),

                  const SizedBox(height: 16),

                  EntryListView(),
                ],
              ),
            );
          } else {
            // Handle case where there's no logged-in user
            return const Center(child: Text("Could not load user data."));
          }
        },
      ),
    );
  }
}