import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../providers/theme_model.dart';
import '../global_keys.dart'; // for navigation
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart'; // <-- needed for redirect after logout

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeModel>(context);
    final accent = theme.accent;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Settings",
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => shellKey.currentState?.goToTab(0),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // PREVIEW CIRCLE
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black12, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // ACCENT COLOR CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Accent Color",
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.color_lens_outlined),
                    label: const Text("Choose Color"),
                    onPressed: () => _openColorPicker(context, theme),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // THEME TOGGLE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Dark Mode", style: TextStyle(fontSize: 16)),
                Switch(
                  value: theme.isDark,
                  activeThumbColor: accent,
                  onChanged: (v) => theme.setDarkMode(v),
                ),
              ],
            ),

            const SizedBox(height: 25),

            //  LOGOUT BUTTON
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text("Log Out"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _logout,
            ),

            const SizedBox(height: 40),

            // App version footer
            Center(
              child: Text(
                "LockIn v1.0",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // COLOR PICKER LOGIC
  void _openColorPicker(BuildContext context, ThemeModel theme) {
    Color tempColor = theme.accent;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Pick Accent Color"),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: tempColor,
            onColorChanged: (c) => tempColor = c,
            enableAlpha: false,
            displayThumbColor: true,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              theme.setAccent(tempColor);
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // LOGOUT FUNCTION
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}
