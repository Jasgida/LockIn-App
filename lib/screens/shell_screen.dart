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
  int _currentIndex = 0;

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(onTabChange: _changeTab), // ← REQUIRED ARGUMENT ADDED
          const FocusTimerScreen(),
          const JournalScreen(),
          const AppBlockerScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _changeTab,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.timer_outlined), label: 'Focus'),
          BottomNavigationBarItem(icon: Icon(Icons.book_outlined), label: 'Journal'),
          BottomNavigationBarItem(icon: Icon(Icons.block), label: 'Blocker'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}