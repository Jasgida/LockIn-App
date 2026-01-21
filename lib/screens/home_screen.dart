// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/focus_model.dart';
import '../utils/quotes_manager.dart';
import '../models/quote.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int) onTabChange;

  const HomeScreen({super.key, required this.onTabChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String _quote = "Stay focused. Your future is watching.";
  String _author = "LockIn";
  String _greeting = 'Hey';
  String _todayFocus = '0m';
  int _streak = 0;
  String userName = 'User';

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadEverything();
    _loadUserName();

    // PULSE ANIMATION FOR START BUTTON
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String name = user.displayName ?? '';
      if (name.isEmpty && user.email != null) {
        String emailPart = user.email!.split('@')[0];
        name = emailPart.split('.').map((part) {
          if (part.isEmpty) return '';
          return part[0].toUpperCase() + part.substring(1).toLowerCase();
        }).join(' ');
      }
      if (name.isEmpty) name = 'User';

      if (mounted) {
        setState(() {
          userName = name;
        });
      }
    }
  }

  Future<void> _loadEverything() async {
    final Quote quoteObj = await QuotesManager.getQuoteForNow();
    final focus = Provider.of<FocusModel>(context, listen: false);
    await focus.refreshForDate(DateTime.now());

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 18
            ? 'Good afternoon'
            : 'Good evening';

    if (mounted) {
      setState(() {
        _quote = quoteObj.quote.isNotEmpty ? quoteObj.quote : "Discipline is the bridge between goals and accomplishment.";
        _author = quoteObj.author.isNotEmpty ? quoteObj.author : "LockIn";
        _greeting = greeting;
        _todayFocus = '${focus.todayMinutes}m';
        _streak = focus.streak;
      });
    }
  }

  void _startFocus() {
    widget.onTabChange(1);
  }

  void _openSettings() {
    widget.onTabChange(4);
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadEverything,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
          children: [
            // LIVELY GREETING
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                    children: [
                      TextSpan(text: '$_greeting, '),
                      TextSpan(
                        text: userName,
                        style: TextStyle(color: accent, fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' 👋'),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _openSettings,
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Ready to crush it today?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
            ),
            const SizedBox(height: 30),

            // PULSING START BUTTON
            Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: GestureDetector(
                      onTap: _startFocus,
                      child: Container(
                        width: 260,
                        height: 260,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [accent.withOpacity(0.3), Colors.white],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withOpacity(0.5),
                              blurRadius: 40,
                              spreadRadius: 15,
                            ),
                          ],
                          border: Border.all(color: accent, width: 8),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'START',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: accent,
                                ),
                              ),
                              Text(
                                'FOCUS',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: accent,
                                ),
                              ),
                              Text(
                                'SESSION',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 40),

            // TODAY'S FOCUS & STREAK
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      "Today's Focus",
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _todayFocus,
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_fire_department, size: 40, color: Colors.orange[700]),
                        const SizedBox(width: 12),
                        Text(
                          'Day $_streak',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Streak!',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange[700]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // MOTIVATION QUOTE
            Text(
              'Daily Motivation',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent.withOpacity(0.2), accent.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: accent.withOpacity(0.4), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '"$_quote"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      height: 1.8,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "— $_author —",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}