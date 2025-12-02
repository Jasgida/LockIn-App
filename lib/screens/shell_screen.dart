import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'focus_timer_screen.dart';
import 'journal_screen.dart';
import 'settings_screen.dart';
import 'blocker_screen.dart';        // ← NEW IMPORT

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  ShellScreenState createState() => ShellScreenState();
}

class ShellScreenState extends State<ShellScreen> {
  int _selectedIndex = 0;

  // ← NOW 5 SCREENS (Blocker added at the end)
  final List<Widget> _screens = const [
    HomeScreen(),
    FocusTimerScreen(),
    JournalScreen(),
    BlockerScreen(),     // ← NEW SCREEN
    SettingsScreen(),
  ];

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
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.timer_outlined), label: 'Focus'),
          BottomNavigationBarItem(icon: Icon(Icons.book_outlined), label: 'Journal'),
          BottomNavigationBarItem(icon: Icon(Icons.block), label: 'Blocker'),   // ← NEW TAB
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}