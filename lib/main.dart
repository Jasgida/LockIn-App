// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:flutter/foundation.dart'; // ← FOR debugPrint

import 'firebase_options.dart';
import 'providers/theme_model.dart';
import 'providers/focus_model.dart';
import 'providers/journal_model.dart';
import 'providers/blocker_provider.dart';
import 'services/accessibility_blocker.dart';
import 'screens/shell_screen.dart';
import 'screens/login_screen.dart';
import 'screens/email_verification_screen.dart';
import 'utils/quotes_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  QuotesManager.ensureQuotesForToday();

  // LISTEN TO ACCESSIBILITY EVENTS — WITH LOGGING TO SEE IF THEY FIRE
  FlutterAccessibilityService.accessStream.listen((event) {
    debugPrint("ACCESSIBILITY EVENT FIRED!");
    debugPrint("Package: ${event.packageName}");
    debugPrint("Event Type: ${event.eventType}");
    debugPrint("Text: ${event.text}");
    AccessibilityBlocker.checkAndBlock(event.packageName);
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeModel()),
        ChangeNotifierProvider(create: (_) => FocusModel()),
        ChangeNotifierProvider(create: (_) => JournalModel()),
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
          themeMode: theme.isDark ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: theme.accent),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: theme.accent, brightness: Brightness.dark),
          ),
          home: const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;

        if (user == null) {
          return const LoginScreen();
        }

        if (!user.emailVerified) {
          return const EmailVerificationScreen();
        }

        return const ShellScreen();
      },
    );
  }
}