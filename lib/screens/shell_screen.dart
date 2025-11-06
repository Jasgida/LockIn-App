import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'focus_timer_screen.dart'; // ✅ Correct import name
import 'journal_screen.dart';
import 'settings_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  ShellScreenState createState() => ShellScreenState();
}

class ShellScreenState extends State<ShellScreen> {
  int _selectedIndex = 0;

  // ✅ All 4 screens listed here in the same order as your nav bar
  final List<Widget> _screens = const [
    HomeScreen(),
    FocusTimerScreen(), // ✅ match the class name inside focus_time_screen.dart
    JournalScreen(),
    SettingsScreen(),
  ];

  // ✅ Makes navigation work from anywhere (e.g., HomeScreen calls shellKey.currentState?.goToTab(1))
  void goToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: goToTab,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.timer_outlined), label: 'Focus'),
          BottomNavigationBarItem(icon: Icon(Icons.book_outlined), label: 'Journal'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}
