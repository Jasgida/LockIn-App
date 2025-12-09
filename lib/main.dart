// lib/main.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/theme_model.dart';
import 'providers/focus_model.dart';
import 'providers/journal_model.dart';
import 'providers/blocker_provider.dart';
import 'screens/shell_screen.dart';
import 'screens/login_screen.dart';
import 'screens/email_verification_screen.dart';
import 'utils/quotes_manager.dart';

// ONLY THE STUB — NO CONDITIONAL IMPORT (causes build error)
import 'services/pin_overlay_stub.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  QuotesManager.ensureQuotesForToday();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeModel()),
        ChangeNotifierProvider(create: (_) => JournalModel()),
        ChangeNotifierProvider(create: (_) => FocusModel()),
        ChangeNotifierProvider(create: (_) => BlockerProvider()),
      ],
      child: const LockInApp(),
    ),
  );
}

class LockInApp extends StatelessWidget {
  const LockInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, theme, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'LockIn',
          theme: ThemeData(
            fontFamily: 'Inter',
            colorScheme: ColorScheme.fromSeed(seedColor: theme.accent),
            useMaterial3: true,
          ),
          home: const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});
  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  StreamSubscription<User?>? _authSub;

  @override
  void initState() {
    super.initState();
    // PIN overlay will be added in v1.1 — removed for now so APK builds
    // Future updates will bring unbreakable lock
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final user = snapshot.data;
        if (user == null) return const LoginScreen();
        if (!user.emailVerified) return const EmailVerificationScreen();
        return const ShellScreen();
      },
    );
  }
}