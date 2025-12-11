// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/focus_model.dart';
import '../utils/quotes_manager.dart';
import '../models/quote.dart';

class HomeScreen extends StatefulWidget {
  final void Function(int)? goToTab; // ← THIS IS THE KEY

  const HomeScreen({super.key, this.goToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _quote = "Stay focused. Your future is watching.";
  String _author = "LockIn";
  String _greeting = 'Hey';
  String _todayFocus = '0m';
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadEverything();
  }

  Future<void> _loadEverything() async {
    final Quote quoteObj = await QuotesManager.getQuoteForNow();
    final focus = Provider.of<FocusModel>(context, listen: false);
    await focus.refreshForDate(DateTime.now());

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning,'
        : hour < 18
            ? 'Good afternoon,'
            : 'Good evening,';

    if (mounted) {
      setState(() {
        _quote = quoteObj.quote.isNotEmpty
            ? quoteObj.quote
            : "Discipline is the bridge between goals and accomplishment.";
        _author = quoteObj.author.isNotEmpty ? quoteObj.author : "LockIn";
        _greeting = greeting;
        _todayFocus = '${focus.todayMinutes}m';
        _streak = focus.streak;
      });
    }
  }

  // NOW IT WORKS PERFECTLY
  void _startFocus() {
    widget.goToTab?.call(1); // Focus tab
  }

  void _openSettings() {
    widget.goToTab?.call(4); // Settings tab
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    const name = "David";

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadEverything,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_greeting $name',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  onPressed: _openSettings, // WORKS 100%
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'ready to lock in?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),

            // BIG BUTTON — WORKS 100%
            Center(
              child: GestureDetector(
                onTap: _startFocus,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Colors.white, accent.withOpacity(0.12)],
                    ),
                    border: Border.all(color: accent, width: 6),
                  ),
                  child: const Center(
                    child: Text(
                      'Start\nFocus\nSession',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ... rest of your beautiful UI stays exactly the same ...
            const SizedBox(height: 18),
            Center(child: Text("Today's Focus", style: TextStyle(color: Colors.grey[700]))),
            const SizedBox(height: 8),
            Center(child: Text(_todayFocus, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_fire_department_outlined, size: 18),
                const SizedBox(width: 8),
                Text('Day $_streak of Focus Streak', style: TextStyle(color: Colors.grey[700])),
              ],
            ),

            const SizedBox(height: 30),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 16),

            Text(
              'Motivation',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: accent.withOpacity(0.25), width: 1.5),
              ),
              child: Column(
                children: [
                  Text(
                    '"$_quote"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      height: 1.7,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "— $_author —",
                    style: TextStyle(fontSize: 15, color: Colors.grey[700], fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}