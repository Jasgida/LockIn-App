// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/theme_model.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  String? _currentPin;

  @override
  void initState() {
    super.initState();
    _loadCurrentPin();
  }

  Future<void> _loadCurrentPin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentPin = prefs.getString('lockin_pin');
    });
  }

  Future<void> _savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lockin_pin', pin);
    setState(() => _currentPin = pin);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("PIN saved successfully!"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showPinDialog() {
    _pinController.clear();
    _confirmPinController.clear();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Set LockIn PIN", textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("This PIN will lock blocked apps", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              decoration: InputDecoration(
                hintText: "••••",
                counterText: "",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmPinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              decoration: InputDecoration(
                hintText: "Confirm PIN",
                counterText: "",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () {
              final pin = _pinController.text;
              final confirm = _confirmPinController.text;

              if (pin.isEmpty || confirm.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill both fields"), backgroundColor: Colors.red),
                );
                return;
              }

              if (pin != confirm) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("PINs do not match!"), backgroundColor: Colors.red),
                );
                return;
              }

              if (pin.length != 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("PIN must be 4 digits"), backgroundColor: Colors.orange),
                );
                return;
              }

              _savePin(pin);
              Navigator.pop(ctx);
            },
            child: const Text("Save PIN", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openColorPicker(BuildContext context, ThemeModel theme) {
    Color tempColor = theme.accent;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Pick Your Accent Color"),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: tempColor,
            onColorChanged: (c) => tempColor = c,
            enableAlpha: false,
            showLabel: true,
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
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

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

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
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context), // CLEAN & SIMPLE
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // ACCENT COLOR PREVIEW
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

            // ACCENT COLOR PICKER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Accent Color", style: Theme.of(context).textTheme.titleMedium),
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

            // DARK MODE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Dark Mode", style: TextStyle(fontSize: 16)),
                Switch(
                  value: theme.isDark,
                  activeColor: accent,
                  onChanged: (v) => theme.setDarkMode(v),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // PIN LOCK SETUP
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _currentPin != null ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _currentPin != null ? Colors.green : Colors.orange,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _currentPin != null ? Icons.lock : Icons.lock_open,
                        color: _currentPin != null ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("App Lock PIN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          Text(
                            _currentPin != null ? "•••• (Set)" : "Not set",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _showPinDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentPin != null ? Colors.green : Colors.orange,
                    ),
                    child: Text(
                      _currentPin != null ? "Change" : "Set PIN",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // LOGOUT
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text("Log Out"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _logout,
            ),

            const SizedBox(height: 50),

            // VERSION
            Center(
              child: Text(
                "LockIn v1.0 • Unbreakable",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}