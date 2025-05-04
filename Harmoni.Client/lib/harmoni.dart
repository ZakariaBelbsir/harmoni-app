import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:harmoni/screens/calendar/calendar.dart';
import 'package:harmoni/screens/entries/entry/single_entry.dart';
import 'package:harmoni/screens/home/home.dart';
import 'package:harmoni/screens/login/login.dart';
import 'package:harmoni/screens/entries/create/create.dart';
import 'package:harmoni/screens/quotes/favourite_quotes.dart';
import 'package:harmoni/screens/register/register.dart';
import 'package:harmoni/services/authentication_store.dart';
import 'package:harmoni/services/emotion_store.dart';
import 'package:harmoni/services/journal_entry_store.dart';
import 'package:harmoni/services/quote_store.dart';
import 'package:harmoni/services/user_store.dart';
import 'package:harmoni/shared/navbar.dart';
import 'package:harmoni/theme.dart';
import 'package:harmoni/screens/profile/profile.dart';
import 'package:provider/provider.dart';

class Harmoni extends StatelessWidget {
  Harmoni({super.key});

  final GoRouter _router = GoRouter(
    refreshListenable: AuthenticationStore(),
    redirect: (context, state) {
      final bool loggedIn = FirebaseAuth.instance.currentUser != null;
      final bool onAuthPage = state.subloc == '/login' || state.subloc == '/register';

      // Redirect user to login or home page based on auth state
      if (!loggedIn && !onAuthPage) return '/login';
      if (loggedIn && onAuthPage) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const Login(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const Register(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return Navbar(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Home(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const Profile(),
          ),
          GoRoute(
            path: '/stats',
            builder: (context, state) => const Center(
              child: Text("Stats Screen"),
            ),
          ),
          GoRoute(
            path: '/calendar',
            builder: (context, state) => const Calendar(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const Center(
              child: Text("Settings Screen"),
            ),
          ),
          GoRoute(
              path: '/create-entry',
              builder: (context, state) => const CreateEntry()),
          GoRoute(
              path: '/entry/:id',
              builder: (context, state) => SingleEntry(id: state.params["id"]!)
          ),
          GoRoute(path: '/favourite_quotes', builder: (context, state) => const FavouriteQuotes()),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => JournalEntryStore()),
        ChangeNotifierProvider(create: (context) => AuthenticationStore()),
        ChangeNotifierProvider(create: (context) => UserStore()),
        ChangeNotifierProvider(create: (context) => QuoteStore()),
        ChangeNotifierProvider(create: (context) => EmotionStore())
      ],
      child: MaterialApp.router(
        theme: primaryTheme,
        routerConfig: _router,
      ),
    );
  }
}