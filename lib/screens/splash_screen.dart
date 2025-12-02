// lib/screens/splash_screen.dart
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

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      _goToNextScreen();
    });
  }

  void _goToNextScreen() {
    final user = FirebaseAuth.instance.currentUser;

    Widget nextScreen;
    if (user == null) {
      nextScreen = const LoginScreen();
    } else if (user.emailVerified) {
      nextScreen = const ShellScreen();
    } else {
      nextScreen = const EmailVerificationScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextScreen,
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF9C74F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replace with your real asset path
            Image(image: AssetImage('assets/icons/icon.png'), width: 120, height: 120),
            SizedBox(height: 30),
            Text(
              'LockIn',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 80),
            CircularProgressIndicator(color: Colors.black54),
          ],
        ),
      ),
    );
  }
}