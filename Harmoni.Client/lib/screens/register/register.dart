import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:harmoni/screens/login/social_login.dart';
import 'package:harmoni/shared/shared_button.dart';
import 'package:harmoni/shared/shared_text_field.dart';
import 'package:harmoni/shared/shared_text_style.dart';
import 'package:harmoni/shared/shared_title_style.dart';
import 'package:harmoni/theme.dart';
import 'package:provider/provider.dart';
import 'package:harmoni/services/authentication_store.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _registerUser(AuthenticationStore authStore) async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    try {
      await authStore.registerWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _usernameController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Registration failed';
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        case 'email-already-in-use':
          errorMessage = 'Email already in use';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SharedTitleStyle("Register"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/img/LOGO.png",
                  width: 120,
                  height: 120,
                  colorBlendMode: BlendMode.multiply,
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      SharedTextField(
                        controller: _emailController,
                        obscure: false,
                        label: "Email",
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      SharedTextField(
                        controller: _usernameController,
                        obscure: false,
                        label: "Username",
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 16),
                      SharedTextField(
                        controller: _passwordController,
                        obscure: true,
                        label: "Password",
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 16),
                      SharedTextField(
                        controller: _confirmPasswordController,
                        obscure: true,
                        label: "Password Confirmation",
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 16),
                      Consumer<AuthenticationStore>(
                        builder: (context, authStore, child) {
                          return SharedButton(
                            onPressed: authStore.isLoading
                                ? null
                                : () => _registerUser(authStore),
                            backgroundColor: AppColors.mainColor,
                            child: authStore.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const SharedTextStyle("Sign up"),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      const Row(
                        children: [
                          Expanded(child: Divider(color: Colors.black)),
                          SizedBox(width: 8),
                          SharedTextStyle("or"),
                          SizedBox(width: 8),
                          Expanded(child: Divider(color: Colors.black)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const SocialLogin(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SharedTextStyle("Already have an account?"),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => context.push('/login'),
              child: const SharedTextStyle("Sign In"),
            ),
          ],
        ),
      ),
    );
  }
}
