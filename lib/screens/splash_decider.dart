// lib/screens/splash_decider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Small delay for smooth splash feel
    await Future.delayed(const Duration(milliseconds: 1200));

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Not logged in → Login
      _navigateTo(const LoginScreen());
      return;
    }

    // Force refresh user data
    await user.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;

    if (refreshedUser == null) {
      _navigateTo(const LoginScreen());
      return;
    }

    if (refreshedUser.emailVerified) {
      // Fully verified → Main app
      _navigateTo(const ShellScreen()); // ← NO KEY NEEDED
    } else {
      // Logged in but not verified → Verification screen
      _navigateTo(const EmailVerificationScreen());
    }
  }

  void _navigateTo(Widget screen) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // You can add your logo here later
            const Text(
              "LockIn",
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 40),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            const Text(
              "Preparing your focus fortress...",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}