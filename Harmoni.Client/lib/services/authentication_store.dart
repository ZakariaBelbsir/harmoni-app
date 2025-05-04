import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../services/user_store.dart';

class AuthenticationStore extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  final UserStore _userStore = UserStore();

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  AppUser? get currentUser => _userStore.authUser;

  AuthenticationStore() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _userStore.fetchUser(user.uid);
      } else {
        _userStore.clearUser();
      }
      notifyListeners();
    });
  }

  Future<void> registerWithEmailAndPassword(
    String email,
    String password,
    String username,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userCredentials = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredentials.user?.uid)
          .set({
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (userCredentials.user?.uid != null) {
        await _userStore.fetchUser(userCredentials.user!.uid);
      }
      _errorMessage = null;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? "Registration failed";
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      await _userStore.fetchUser(userCredential.user?.uid ?? '');
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = "No user found for that email.";
          break;
        case 'wrong-password':
          _errorMessage = "Incorrect password. Please try again.";
          break;
        case 'invalid-email':
          _errorMessage = "Invalid email address.";
          break;
        default:
          _errorMessage = e.message ?? "Login failed";
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final userCredential =
          await FirebaseAuth.instance.signInWithProvider(GoogleAuthProvider());
      if (userCredential.user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();
        if (!userDoc.exists) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'username': userCredential.user!.displayName ??
                userCredential.user!.email!.split('@').first,
            'email': userCredential.user!.email,
            'profilePicturePath': userCredential.user!.photoURL,
            'createdAt': FieldValue.serverTimestamp()
          });
        }
        await _userStore.fetchUser(userCredential.user!.uid);
      }
    } catch (e) {
      _errorMessage = "Google login failed: ${e.toString()}";
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    _userStore.clearUser();
  }
}
