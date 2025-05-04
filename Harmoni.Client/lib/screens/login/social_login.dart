import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:harmoni/services/authentication_store.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_button/sign_in_button.dart';

class SocialLogin extends StatefulWidget {
  const SocialLogin({super.key});

  @override
  State<SocialLogin> createState() => _SocialLoginState();
}

class _SocialLoginState extends State<SocialLogin> {
  void _handleGoogleLogin() async {
    final authStore = context.read<AuthenticationStore>();

    try {
      await authStore.loginWithGoogle();

      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authStore.errorMessage ?? "Login failed")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return // Social Login Buttons
        Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SignInButton(Buttons.google, onPressed: _handleGoogleLogin),
      ],
    );
  }
}
