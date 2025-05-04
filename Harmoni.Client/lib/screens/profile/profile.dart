import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:harmoni/screens/profile/mood_chart.dart';
import 'package:harmoni/screens/profile/mood_score.dart';
import 'package:harmoni/services/emotion_store.dart';
import 'package:harmoni/shared/shared_title_style.dart';
import 'package:harmoni/theme.dart';
import 'package:provider/provider.dart';
import 'package:harmoni/services/user_store.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    // Fetch emotions when the widget is initialized
    Provider.of<EmotionStore>(context, listen: false).getEmotions();
    super.initState();
  }

  bool _isMoodScoreExpaded = false;
  bool _isMoodChartExpaded = false;

  Future<void> _changeProfilePicture(UserStore userStore) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      try {
        await userStore.pickAndSaveProfilePicture(firebaseUser.uid);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile picture updated successfully!")),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update profile picture: $error")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userStore = Provider.of<UserStore>(context);
    final currentUser = userStore.authUser;

    return Scaffold(
      appBar: AppBar(
        title: SharedTitleStyle('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 16, 16),
        child: Column(
          children: [
            // Profile Details
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: AppColors.paleMint,
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                          width: 200,
                          height: 200,
                          child: Column(
                            children: [
                              SizedBox(height: 16),
                              GestureDetector(
                                onTap: () => _changeProfilePicture(userStore),
                                child: Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundImage: currentUser
                                                  ?.profilePicturePath !=
                                              null
                                          ? FileImage(File(
                                              currentUser!.profilePicturePath!))
                                          : AssetImage(
                                                  "assets/img/user/userpic.jpg")
                                              as ImageProvider,
                                    ),
                                    CircleAvatar(
                                      radius: 15,
                                      backgroundColor: Colors.white,
                                      child: Icon(Icons.camera_alt,
                                          size: 16, color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                '${currentUser?.username ?? "User Name"}\n',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.start,
                              )
                            ],
                          ))
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 16),

            Expanded(
              child: Column(
                children: [
                  Expanded(
                      child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: ListTile(
                          leading: Icon(Icons.score),
                          title: Text("Mood Score"),
                          trailing: Icon(Icons.arrow_drop_down),
                          tileColor: AppColors.secondaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          onTap: () {
                            setState(() {
                              _isMoodScoreExpaded = !_isMoodScoreExpaded;
                            });
                          },
                        ),
                      ),
                      // Animated MoodScore widget container
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        height: _isMoodScoreExpaded ? 200 : 0,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          decoration: BoxDecoration(
                              color: AppColors.offWhite,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2))
                              ]),
                          child: _isMoodScoreExpaded ? MoodScore() : null,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: ListTile(
                          leading: Icon(Icons.assessment),
                          trailing: Icon(Icons.arrow_drop_down),
                          title: Text("Mood Chart"),
                          tileColor: AppColors.secondaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          onTap: () {
                            setState(() {
                              _isMoodChartExpaded = !_isMoodChartExpaded;
                            });
                          },
                        ),
                      ),
                      // Animated MoodChart widget container
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        height: _isMoodChartExpaded ? 200 : 0,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          decoration: BoxDecoration(
                              color: AppColors.offWhite,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2))
                              ]),
                          child: _isMoodChartExpaded ? MoodChart() : null,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: ListTile(
                          leading: Icon(Icons.star_rate),
                          title: Text("Favourite Quotes"),
                          tileColor: AppColors.secondaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          onTap: () {
                            GoRouter.of(context).push('/favourite_quotes');
                          },
                        ),
                      ),
                    ],
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
