// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart'; // For app blocking

import 'firebase_options.dart';
import 'providers/theme_model.dart';
import 'providers/focus_model.dart';
import 'providers/journal_model.dart';
import 'providers/blocker_provider.dart';
import 'services/accessibility_blocker.dart'; // Custom service that handles blocking logic
import 'screens/shell_screen.dart';
import 'screens/login_screen.dart';
import 'screens/email_verification_screen.dart';
import 'utils/quotes_manager.dart';

void main() async {
  // Ensure Flutter bindings are initialized before using any plugins
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (required for Auth, Firestore, etc.)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Load today's motivational quote in the background
  QuotesManager.ensureQuotesForToday();

  // OPTIONAL: Only start listening to accessibility events if permission is granted
  // This prevents crashes when the user hasn't enabled the accessibility service yet
  final isPermissionGranted =
      await FlutterAccessibilityService.isAccessibilityPermissionEnabled();
  if (isPermissionGranted) {
    // Listen to accessibility events (e.g., when user opens an app)
    // When an event is detected, we check if the app should be blocked
    FlutterAccessibilityService.accessStream.listen((event) {
      AccessibilityBlocker.checkAndBlock(event.packageName);
    });
  }

  // Start the app with all providers (state management)
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeModel()),           // Dark/light mode & accent color
        ChangeNotifierProvider(create: (_) => FocusModel()),           // Focus timer & streak
        ChangeNotifierProvider(create: (_) => JournalModel()),         // Journal entries
        ChangeNotifierProvider(create: (_) => BlockerProvider()),      // App blocker list & usage
      ],
      child: const LockInApp(),
    ),
  );
}

class LockInApp extends StatelessWidget {
  const LockInApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuild the entire MaterialApp when theme changes
    return Consumer<ThemeModel>(
      builder: (context, theme, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'LockIn',
          // Switch between light and dark theme based on user preference
          themeMode: theme.isDark ? ThemeMode.dark : ThemeMode.light,
          // Light theme
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: theme.accent),
            scaffoldBackgroundColor: Colors.grey[50],
          ),
          // Dark theme
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: theme.accent,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: Colors.black,
          ),
          // First screen shown — decides login / verification / main app
          home: const AuthWrapper(),
        );
      },
    );
  }
}

// Handles authentication state: logged in? email verified? show correct screen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // Listens to login/logout
      builder: (context, snapshot) {
        // Show loading spinner while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;

        // Not logged in → show login screen
        if (user == null) {
          return const LoginScreen();
        }

        // Logged in but email not verified → show verification screen
        if (!user.emailVerified) {
          return const EmailVerificationScreen();
        }

        // Everything good → show main app with bottom navigation
        return const ShellScreen();
      },
    );
  }
}