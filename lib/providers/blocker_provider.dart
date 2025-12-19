// lib/providers/blocker_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart'; // ← ADD THIS
import 'package:app_usage/app_usage.dart';

class BlockedApp {
  final String packageName;
  final String appName;
  final int dailyLimitMinutes;

  BlockedApp({
    required this.packageName,
    required this.appName,
    this.dailyLimitMinutes = 30,
  });
}

class BlockerProvider extends ChangeNotifier {
  List<AppInfo> allApps = [];
  List<BlockedApp> blockedApps = [];
  Map<String, int> todayUsage = {};
  bool isLoading = true;

  final User? user = FirebaseAuth.instance.currentUser;

  BlockerProvider() {
    if (user != null) {
      loadEverything();
    }
  }

  Future<void> loadEverything() async {
    isLoading = true;
    notifyListeners();

    await Future.wait([
      _loadInstalledApps(),
      _loadBlockedAppsFromFirestore(),
      _loadTodayUsage(),
    ]);

    isLoading = false;
    notifyListeners();
  }

  Future<void> _loadInstalledApps() async {
    try {
      final apps = await InstalledApps.getInstalledApps(true, true); // exclude system, with icon

      allApps = apps;

      allApps.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } catch (e) {
      debugPrint('Failed to load installed apps: $e');
      allApps = [];
    }
  }

  Future<void> _loadBlockedAppsFromFirestore() async {
    if (user == null) {
      blockedApps = [];
      return;
    }

    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('blocked_apps')
          .get();

      blockedApps = snap.docs.map((doc) {
        final data = doc.data();
        return BlockedApp(
          packageName: doc.id,
          appName: data['name'] ?? 'Unknown App',
          dailyLimitMinutes: data['limit'] ?? 30,
        );
      }).toList();
    } catch (e) {
      debugPrint('Failed to load blocked apps: $e');
      blockedApps = [];
    }
  }

  Future<void> _loadTodayUsage() async {
    try {
      final appUsage = AppUsage();
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final usageList = await appUsage.getAppUsage(startOfDay, now);

      todayUsage = {
        for (var info in usageList)
          info.packageName: info.usage.inMinutes
      };
    } catch (e) {
      debugPrint('App usage not available: $e');
      todayUsage = {};
    }
  }

  Future<void> toggleBlock(AppInfo app) async {
    if (user == null) return;

    final alreadyBlocked = blockedApps.any((b) => b.packageName == app.packageName);

    if (alreadyBlocked) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('blocked_apps')
          .doc(app.packageName)
          .delete();

      blockedApps.removeWhere((b) => b.packageName == app.packageName);
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('blocked_apps')
          .doc(app.packageName)
          .set({
        'name': app.name,
        'limit': 30,
        'blockedAt': FieldValue.serverTimestamp(),
      });

      blockedApps.add(BlockedApp(
        packageName: app.packageName,
        appName: app.name,
      ));
    }

    notifyListeners();
  }

  bool isBlocked(String packageName) =>
      blockedApps.any((b) => b.packageName == packageName);
}