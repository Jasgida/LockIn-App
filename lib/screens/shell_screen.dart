import 'package:flutter/material.dart';
import 'settings_screen.dart';
import '../providers/theme_model.dart';
import 'package:provider/provider.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  ShellScreenState createState() => ShellScreenState();
}

class ShellScreenState extends State<ShellScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    // replace with your actual pages
    Center(child: Text("Home Screen")),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
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
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
