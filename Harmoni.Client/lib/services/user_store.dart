import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';

class UserStore extends ChangeNotifier {
  AppUser? _authUser;

  AppUser? get authUser => _authUser;
  bool _isFetching = false;

  bool get isFetching => _isFetching;

  Future<void> fetchUser(String uid) async {
    _isFetching = true;
    notifyListeners();
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .withConverter<AppUser>(
            fromFirestore: AppUser.fromFirestore,
            toFirestore: (AppUser user, SetOptions? options) =>
                user.toFirestore(),
          )
          .get();
      if (userDoc.exists && userDoc.data() != null) {
        _authUser = userDoc.data()!;
      } else {
        _authUser = null;
      }
    } catch (e) {
      print("Error fetching user: $e");
      _authUser = null;
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  Future<void> updateUsername(String userId, String newUsername) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'username': newUsername});

    if (_authUser != null) {
      _authUser = _authUser!.copyWith(username: newUsername);
      notifyListeners();
    }
  }

  Future<void> saveProfilePictureLocally(String userId, File imageFile) async {
    try {
      // Get the app's documents directory
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/profile_picture_$userId.png';

      // Save the image locally
      await imageFile.copy(filePath);

      debugPrint("Image saved locally at: $filePath");

      // Update Firestore with the local file path
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'profilePicturePath': filePath});

      // Update local state
      if (_authUser != null) {
        _authUser = _authUser!.copyWith(profilePicturePath: filePath);
        notifyListeners();
      }
    } catch (error) {
      rethrow; // Rethrow the error to handle it in the UI
    }
  }

  Future<void> pickAndSaveProfilePicture(String userId) async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      await saveProfilePictureLocally(userId, imageFile);
    }
  }

  void clearUser() {
    _authUser = null;
    notifyListeners();
  }
}
