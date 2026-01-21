// lib/services/accessibility_blocker.dart
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:flutter_accessibility_service/constants.dart'; // ← THIS FIXES GlobalAction
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccessibilityBlocker {
  static bool isEnabled = false;

  static Future<void> startBlocking() async {
    isEnabled = true;
    final isGranted = await FlutterAccessibilityService.isAccessibilityPermissionEnabled();
    if (!isGranted) {
      await FlutterAccessibilityService.requestAccessibilityPermission();
    }
  }

  static void stopBlocking() {
    isEnabled = false;
    FlutterAccessibilityService.hideOverlayWindow();
  }

  static Future<void> checkAndBlock(String? packageName) async {
    if (!isEnabled || packageName == null || packageName.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('blocked_apps')
        .doc(packageName)
        .get();

    if (doc.exists) {
      // SHOW OVERLAY + CLOSE APP
      await FlutterAccessibilityService.showOverlayWindow();
      await FlutterAccessibilityService.performGlobalAction(GlobalAction.globalActionHome);
    }
  }
}