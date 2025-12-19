// lib/screens/shell_screen.dart
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'focus_timer_screen.dart';
import 'journal_screen.dart';
import 'app_blocker_screen.dart';
import 'settings_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;

  void _onTabTapped(int index) {
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onTabChange: _onTabTapped), // ← REQUIRED ARGUMENT ADDED
          const FocusTimerScreen(),
          const JournalScreen(),
          const AppBlockerScreen(),
          const SettingsScreen(),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
            selectedItemColor: accent,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
              BottomNavigationBarItem(icon: Icon(Icons.timer_rounded), label: "Focus"),
              BottomNavigationBarItem(icon: Icon(Icons.book_rounded), label: "Journal"),
              BottomNavigationBarItem(icon: Icon(Icons.block_rounded), label: "Blocker"),
              BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: "Settings"),
            ],
          ),
        ),
      ),
    );
  }
}