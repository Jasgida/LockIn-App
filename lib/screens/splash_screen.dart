import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'shell_screen.dart';
import 'login_screen.dart';
import 'email_verification_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Fade animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // After delay, check auth state
    Timer(const Duration(seconds: 3), _checkAuthState);
  }

  Future<void> _checkAuthState() async {
    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (user == null) {
      // 🔥 Not logged in → Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    // Reload to get updated verification status
    await user.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;

    if (refreshedUser!.emailVerified) {
      // 🔥 Logged in + verified → Home (Shell)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ShellScreen()),
      );
    } else {
      // 🔥 Logged in but NOT verified → Email Verification Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EmailVerificationScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9C74F),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/icons/icon.png',
                height: 120,
                width: 120,
              ),
              const SizedBox(height: 20),
              const Text(
                'LockIn',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
