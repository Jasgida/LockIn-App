// lib/services/pin_overlay_service.dart
// REAL ANDROID VERSION — ONLY USED ON PHONES
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import '../widgets/pin_lock_screen.dart';

class PinOverlayService {
  static final PinOverlayService _instance = PinOverlayService._();
  factory PinOverlayService() => _instance;
  PinOverlayService._();

  OverlayEntry? _overlayEntry;
  StreamSubscription? _subscription;

  Future<void> start() async {
    await FlutterAccessibilityService.requestAccessibilityPermission();

    _subscription = FlutterAccessibilityService.accessibilityEventStream.listen((event) async {
      if (event.packageName == null || event.eventType != AccessibilityEventType.typeWindowStateChanged) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final blocked = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('blocked_apps')
          .doc(event.packageName)
          .get();

      if (blocked.exists) {
        _showPinOverlay();
        await Future.delayed(const Duration(milliseconds: 200));
        await FlutterAccessibilityService.performGlobalAction(GlobalAction.back);
      }
    });
  }

  void _showPinOverlay() {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (_) => PinLockScreen(
        onCorrectPin: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
        },
        onWrongPin: () async {
          if (await Vibrate.canVibrate) {
            Vibrate.feedback(FeedbackType.heavy);
          }
        },
      ),
    );
    Overlay.of(WidgetsBinding.instance.rootElement!)?.insert(_overlayEntry!);
  }

  void stop() {
    _subscription?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}