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

  // THIS IS THE MAGIC METHOD YOUR HOME SCREEN WILL CALL
  void goToTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens.map((screen) {
          // Wrap HomeScreen so it can call goToTab()
          if (screen is HomeScreen) {
            return HomeScreenWithNavigation(goToTab: goToTab);
          }
          return screen;
        }).toList(),
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

// NEW WRAPPER SO HOME SCREEN CAN CALL goToTab()
class HomeScreenWithNavigation extends StatelessWidget {
  final void Function(int) goToTab;

  const HomeScreenWithNavigation({super.key, required this.goToTab});

  @override
  Widget build(BuildContext context) {
    return HomeScreen(goToTab: goToTab);
  }
}