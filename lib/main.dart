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

// THIS ONE LINE FIXES EVERYTHING
import 'services/pin_overlay_stub.dart'
    if (dart.library.io) 'services/pin_overlay_service.dart';

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

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user != null && user.emailVerified) {
          PinOverlayService().start();
          EmergencyEscape.startListening();
        } else {
          PinOverlayService().stop();
          EmergencyEscape.stopListening();
        }
      });
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    EmergencyEscape.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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