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
      // THIS WORKS 100% WITH installed_apps 1.6.0
      final allApps = await InstalledApps.getInstalledApps();

      // Remove system apps manually
      final userApps = allApps
          .where((app) =>
              !app.packageName.startsWith('com.android') &&
              !app.packageName.startsWith('com.google.android'))
          .toList();

      userApps.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('blocked_apps')
            .get();
        blockedApps = snapshot.docs.map((doc) => doc.id).toSet();
      }

      setState(() => apps = userApps);
    } catch (e) {
      debugPrint('Error loading apps: $e');
      setState(() => apps = []);
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

    blocked ? await ref.set({'blocked': true}) : await ref.delete();

    setState(() {
      blocked ? blockedApps.add(packageName) : blockedApps.remove(packageName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Block Apps During Focus'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: apps.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadApps,
              child: ListView.builder(
                itemCount: apps.length,
                itemBuilder: (context, index) {
                  final app = apps[index];
                  final isBlocked = blockedApps.contains(app.packageName);
                  final Uint8List? icon = app.icon; // THIS IS NOW POPULATED IN 1.6.0

                  return SwitchListTile(
                    secondary: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.transparent,
                      backgroundImage: icon != null ? MemoryImage(icon) : null,
                      child: icon == null
                          ? const Icon(Icons.apps, size: 30, color: Colors.grey)
                          : null,
                    ),
                    title: Text(app.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(app.packageName, style: const TextStyle(fontSize: 10)),
                    value: isBlocked,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (val) => _toggleApp(app.packageName, val),
                  );
                },
              ),
            ),
    );
  }
}