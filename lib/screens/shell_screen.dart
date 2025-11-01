import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'focus_timer_screen.dart';
import 'stats_screen.dart';
import 'journal_screen.dart';
import 'settings_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  ShellScreenState createState() => ShellScreenState();
}

// ✅ Public class so the key can access it
class ShellScreenState extends State<ShellScreen> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    FocusTimerScreen(),
    StatsScreen(),
    JournalScreen(),
    SettingsScreen(),
  ];

  // ✅ Expose method for navigation
  void goToTab(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (v) => setState(() => _index = v),
        selectedItemColor: accent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Focus'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Journal'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
