// lib/screens/blocked_overlay.dart
import 'package:flutter/material.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:flutter_accessibility_service/constants.dart'; // ← FOR GlobalAction

@pragma("vm:entry-point")
void accessibilityOverlay() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: BlockedOverlay(),
  ));
}

class BlockedOverlay extends StatelessWidget {
  const BlockedOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withAlpha(230), // ← FIXED deprecation (instead of withOpacity)
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              "APP BLOCKED",
              style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              "Focus mode is active.\nThis app is blocked until focus ends.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                FlutterAccessibilityService.performGlobalAction(GlobalAction.globalActionHome);
              },
              child: const Text("Go Home"),
            ),
          ],
        ),
      ),
    );
  }
}