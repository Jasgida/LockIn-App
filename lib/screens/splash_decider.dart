import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../global_keys.dart';
import 'login_screen.dart';
import 'shell_screen.dart';
import 'email_verification_screen.dart';

class SplashDecider extends StatefulWidget {
  const SplashDecider({super.key});

  @override
  State<SplashDecider> createState() => _SplashDeciderState();
}

class _SplashDeciderState extends State<SplashDecider> {
  @override
  void initState() {
    super.initState();
    _navigateUser();
  }

  Future<void> _navigateUser() async {
    await Future.delayed(const Duration(seconds: 1)); // Small smooth delay

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // ❌ Not logged in → Login Screen
      _go(const LoginScreen());
      return;
    }

    await user.reload();
    final refreshed = FirebaseAuth.instance.currentUser;

    if (refreshed!.emailVerified) {
      // ✔ Email verified → Shell/Home Screen
      _go(ShellScreen(key: shellKey));
    } else {
      // ⚠ Logged in but NOT verified → Email Verification Screen
      _go(const EmailVerificationScreen());
    }
  }

  void _go(Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
