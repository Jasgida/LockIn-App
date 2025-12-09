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

// THIS NAME MUST BE _ShellScreenState (with underscore)
class _ShellScreenState extends State<ShellScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    FocusTimerScreen(),
    JournalScreen(),
    AppBlockerScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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