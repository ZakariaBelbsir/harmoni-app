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

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 🔹 Handles user login
  Future<void> _handleLogin() async {
    final authStore = context.read<AuthenticationStore>();

    try {
      await authStore.loginWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        context.go('/'); // Redirect to home on successful login
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
    return Scaffold(
      appBar: AppBar(
        title: const SharedTitleStyle("Login"),
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
                        controller: _passwordController,
                        obscure: true,
                        label: "Password",
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 16),
                      Consumer<AuthenticationStore>(
                        builder: (context, authStore, child) {
                          return SharedButton(
                            onPressed:
                                authStore.isLoading ? null : _handleLogin,
                            backgroundColor: AppColors.mainColor,
                            child: authStore.isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const SharedTextStyle("Sign in"),
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
            const SharedTextStyle("Don't have an account?"),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => context.push('/register'),
              child: const SharedTextStyle("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
