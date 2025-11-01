import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/focus_model.dart';
import '../utils/quotes_manager.dart';
import '../models/quote.dart'; // ✅ import the Quote model
import '../main.dart'; // ✅ import for shellKey

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _quote = '';
  String _author = '';
  String _greeting = 'Hey';
  String _todayFocus = '0m';
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadQuoteAndStats();
  }

  Future<void> _loadQuoteAndStats() async {
    final Quote quoteObj = await QuotesManager.getQuoteForNow(); // ✅ now returns Quote
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = (hour < 12)
        ? 'Good morning,'
        : (hour < 18)
            ? 'Good afternoon,'
            : 'Good evening,';
    final focus = Provider.of<FocusModel>(context, listen: false);
    await focus.refreshForDate(DateTime.now());

    setState(() {
      _quote = quoteObj.quote;
      _author = quoteObj.author;
      _greeting = greeting;
      _todayFocus = '${focus.todayMinutes}m';
      _streak = focus.streak;
    });
  }

  void _startFocus() {
    shellKey.currentState?.goToTab(1);
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final name = "David";

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await QuotesManager.ensureQuotesForToday();
          await _loadQuoteAndStats();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$_greeting $name',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () => shellKey.currentState?.goToTab(4),
                  icon: const Icon(Icons.settings_outlined),
                )
              ],
            ),
            const SizedBox(height: 6),
            Text('ready to lock in?',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
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
                  child: Center(
                    child: Text(
                      'Start\nFocus\nSession',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Center(
                child: Text("Today's Focus",
                    style: TextStyle(color: Colors.grey[700]))),
            const SizedBox(height: 8),
            Center(
                child: Text(_todayFocus,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_fire_department_outlined, size: 18),
                const SizedBox(width: 8),
                Text('Day $_streak of Focus Streak',
                    style: TextStyle(color: Colors.grey[700])),
              ],
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('Motivation', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    _quote,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "- $_author",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
