// lib/screens/app_blocker_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppBlockerScreen extends StatefulWidget {
  const AppBlockerScreen({super.key});

  @override
  State<AppBlockerScreen> createState() => _AppBlockerScreenState();
}

class _AppBlockerScreenState extends State<AppBlockerScreen> {
  List<AppInfo> apps = [];
  Set<String> blockedApps = {};

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    try {
      final allApps = await InstalledApps.getInstalledApps(); // ← NEW API
      allApps.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('blocked_apps')
            .get();
        blockedApps = snapshot.docs.map((doc) => doc.id).toSet();
      }

      setState(() => apps = allApps);
    } catch (e) {
      print("Error loading apps: $e");
    }
  }

  Future<void> _toggleApp(String packageName, bool blocked) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('blocked_apps')
        .doc(packageName);

    if (blocked) {
      await ref.set({'blocked': true});
    } else {
      await ref.delete();
    }

    setState(() {
      blocked ? blockedApps.add(packageName) : blockedApps.remove(packageName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Block Apps During Focus"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: apps.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final app = apps[index];
                final isBlocked = blockedApps.contains(app.packageName);
                Uint8List? icon = app.icon;

                return SwitchListTile(
                  secondary: CircleAvatar(
                    backgroundImage: icon != null ? MemoryImage(icon) : null,
                    child: icon == null ? const Icon(Icons.android) : null,
                  ),
                  title: Text(app.name),
                  subtitle: Text(app.packageName, style: const TextStyle(fontSize: 11)),
                  value: isBlocked,
                  onChanged: (val) => _toggleApp(app.packageName, val),
                );
              },
            ),
    );
  }
}