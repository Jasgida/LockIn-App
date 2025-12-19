// lib/screens/app_blocker_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ADD THESE IF YOU HAVE BLOCKING SERVICE
// import 'package:your_blocking_service/your_service.dart'; // e.g. accessibility or overlay

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
      final allApps = await InstalledApps.getInstalledApps(true, true);

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
      debugPrint("Error loading apps: $e");
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

    try {
      if (blocked) {
        await ref.set({'blocked': true});
      } else {
        await ref.delete();
      }
    } catch (e) {
      debugPrint("Firestore error: $e");
    }

    // INSTANT LOCAL UPDATE — NO DELAY
    setState(() {
      if (blocked) {
        blockedApps.add(packageName);
      } else {
        blockedApps.remove(packageName);
      }
    });

    // INSTANT BLOCK/UNBLOCK — CALL YOUR BLOCKING SERVICE HERE
    // Example if you have an accessibility service or overlay:
    // if (blocked) {
    //   YourBlockingService.blockApp(packageName);
    // } else {
    //   YourBlockingService.unblockApp(packageName);
    // }

    // Or if you have a broadcast or method channel:
    // YourMethodChannel.invokeMethod('blockApp', {'package': packageName, 'block': blocked});
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
          : RefreshIndicator(
              onRefresh: _loadApps,
              child: ListView.builder(
                itemCount: apps.length,
                itemBuilder: (context, index) {
                  final app = apps[index];
                  final isBlocked = blockedApps.contains(app.packageName);
                  Uint8List? iconBytes = app.icon;

                  return SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    secondary: CircleAvatar(
                      radius: 30,
                      backgroundImage: iconBytes != null ? MemoryImage(iconBytes) : null,
                      child: iconBytes == null
                          ? const Icon(Icons.apps, size: 30, color: Colors.grey)
                          : null,
                    ),
                    title: Text(app.name, style: const TextStyle(fontSize: 18)),
                    subtitle: Text(app.packageName, style: const TextStyle(fontSize: 12)),
                    value: isBlocked,
                    onChanged: (val) => _toggleApp(app.packageName, val),
                    activeColor: Theme.of(context).colorScheme.primary,
                    activeTrackColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  );
                },
              ),
            ),
    );
  }
}