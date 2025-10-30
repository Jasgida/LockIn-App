// lib/main.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'data/quotes.dart';

// ------------------------------
// Model: Journal Entry
// ------------------------------
class JournalEntry {
  final String id;
  final String text;
  final DateTime date;
  final int minutes;

  JournalEntry({
    required this.id,
    required this.text,
    required this.date,
    required this.minutes,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'date': date.toIso8601String(),
        'minutes': minutes,
      };

  factory JournalEntry.fromMap(Map<String, dynamic> map) => JournalEntry(
        id: map['id'] ?? '',
        text: map['text'] ?? '',
        date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
        minutes: (map['minutes'] ?? 0) as int,
      );
}

// ------------------------------
// Provider: ThemeModel
// ------------------------------
class ThemeModel extends ChangeNotifier {
  Color _accent = const Color(0xFF2FB3A6);
  Color get accent => _accent;
  static const _prefsKey = 'lockin_theme_color';

  ThemeModel() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getInt(_prefsKey);
    if (v != null) {
      _accent = Color(v);
      notifyListeners();
    }
  }

  Future<void> setAccent(Color c) async {
    _accent = c;
    notifyListeners();
    final p = await SharedPreferences.getInstance();
    await p.setInt(_prefsKey, c.value);
  }
}

// ------------------------------
// Focus stats: store today's minutes and streak
// ------------------------------
class FocusModel extends ChangeNotifier {
  static const _prefs_today_key = 'focus_today_minutes';
  static const _prefs_date_key = 'focus_last_date';
  static const _prefs_streak_key = 'focus_streak';

  int _todayMinutes = 0;
  int get todayMinutes => _todayMinutes;

  int _streak = 0;
  int get streak => _streak;

  FocusModel() {
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final todayKey = _todayKeyForDate(DateTime.now());
    _todayMinutes = p.getInt(_prefs_today_key) ?? 0;
    _streak = p.getInt(_prefs_streak_key) ?? 0;
    // If stored date is not today, zero today's minutes (we will keep persisted by date)
    final lastDate = p.getString(_prefs_date_key);
    final todayStr = _dateString(DateTime.now());
    if (lastDate != todayStr) {
      // load from keyed storage if exists
      _todayMinutes = p.getInt(todayKey) ?? 0;
      notifyListeners();
    }
  }

  String _dateString(DateTime d) => '${d.year}-${d.month}-${d.day}';
  String _todayKeyForDate(DateTime d) => 'focus_minutes_${_dateString(d)}';

  Future<void> addMinutes(int minutes) async {
    final p = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayKey = _todayKeyForDate(today);
    final lastDateStr = p.getString(_prefs_date_key);
    final lastDate = lastDateStr == null ? null : DateTime.tryParse(lastDateStr);
    // update today's minutes
    final prev = p.getInt(todayKey) ?? 0;
    final updated = prev + minutes;
    await p.setInt(todayKey, updated);
    _todayMinutes = updated;

    // update streak logic
    final todayStr = _dateString(today);
    if (lastDateStr == null) {
      // first time
      _streak = 1;
    } else {
      final last = DateTime.tryParse(lastDateStr);
      if (last != null) {
        final yesterday = DateTime(today.year, today.month, today.day - 1);
        if (_dateString(last) == _dateString(yesterday)) {
          // continued streak
          _streak = (p.getInt(_prefs_streak_key) ?? 0) + 1;
        } else if (_dateString(last) == _dateString(today)) {
          // same day: keep existing streak
          _streak = p.getInt(_prefs_streak_key) ?? 1;
        } else {
          // break streak, start at 1
          _streak = 1;
        }
      } else {
        _streak = 1;
      }
    }
    await p.setInt(_prefs_streak_key, _streak);
    await p.setString(_prefs_date_key, today.toIso8601String());
    notifyListeners();
  }

  Future<void> refreshForDate(DateTime date) async {
    final p = await SharedPreferences.getInstance();
    final key = _todayKeyForDate(date);
    _todayMinutes = p.getInt(key) ?? 0;
    notifyListeners();
  }
}

// ------------------------------
// Service: FirebaseDB (Journal)
// ------------------------------
class FirebaseDbService {
  final _db = FirebaseFirestore.instance;

  Future<void> saveJournal(JournalEntry entry) async {
    await _db.collection('journal').doc(entry.id).set(entry.toMap());
  }

  Future<List<JournalEntry>> fetchEntries() async {
    final snap =
        await _db.collection('journal').orderBy('date', descending: true).get();
    return snap.docs
        .map((d) => JournalEntry.fromMap(d.data()))
        .toList(growable: false);
  }

  Future<void> deleteEntry(String id) async {
    await _db.collection('journal').doc(id).delete();
  }
}

// ------------------------------
// Provider: JournalModel
// ------------------------------
class JournalModel extends ChangeNotifier {
  static const _prefsKey = 'lockin_journal_entries';
  final List<JournalEntry> _items = [];
  final FirebaseDbService _firebase = FirebaseDbService();

  List<JournalEntry> get items => List.unmodifiable(_items);

  JournalModel() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List;
        _items.addAll(
            list.map((e) => JournalEntry.fromMap(Map<String, dynamic>.from(e))));
      }
    } catch (_) {}

    try {
      final cloud = await _firebase.fetchEntries();
      for (final e in cloud) {
        if (!_items.any((i) => i.id == e.id)) _items.add(e);
      }
      _items.sort((a, b) => b.date.compareTo(a.date));
      await _save();
      notifyListeners();
    } catch (e) {
      debugPrint('Firestore sync error: $e');
    }
  }

  Future<void> add(JournalEntry e) async {
    _items.insert(0, e);
    notifyListeners();
    await _save();
    try {
      await _firebase.saveJournal(e);
    } catch (err) {
      debugPrint('Cloud save failed: $err');
    }
  }

  Future<void> remove(String id) async {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
    await _save();
    try {
      await _firebase.deleteEntry(id);
    } catch (err) {
      debugPrint('Cloud delete failed: $err');
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _prefsKey, jsonEncode(_items.map((e) => e.toMap()).toList()));
  }
}

// ------------------------------
// Quotes manager (two quotes per day)
/// Stores chosen indices for current day and returns AM/PM quote
// ------------------------------
class QuotesManager {
  static const _prefs_date = 'quotes_date';
  static const _prefs_am = 'quotes_am_index';
  static const _prefs_pm = 'quotes_pm_index';

  static Future<void> ensureQuotesForToday() async {
    final p = await SharedPreferences.getInstance();
    final todayStr = _dateString(DateTime.now());
    final stored = p.getString(_prefs_date);
    if (stored == todayStr) return; // already set for today

    // pick two distinct random indices
    final rng = Random();
    final int total = motivationalQuotes.length;
    if (total == 0) return;
    int a = rng.nextInt(total);
    int b = rng.nextInt(total);
    // ensure different if possible
    if (total > 1) {
      while (b == a) {
        b = rng.nextInt(total);
      }
    }
    await p.setString(_prefs_date, todayStr);
    await p.setInt(_prefs_am, a);
    await p.setInt(_prefs_pm, b);
  }

  static Future<String> getQuoteForNow() async {
    final p = await SharedPreferences.getInstance();
    final todayStr = _dateString(DateTime.now());
    final stored = p.getString(_prefs_date);
    if (stored != todayStr) {
      await ensureQuotesForToday();
    }
    final hour = DateTime.now().hour;
    final am = p.getInt(_prefs_am) ?? 0;
    final pm = p.getInt(_prefs_pm) ?? 0;
    final index = (hour < 12) ? am : pm;
    if (motivationalQuotes.isEmpty) return '';
    final safeIndex = index % motivationalQuotes.length;
    return motivationalQuotes[safeIndex];
  }

  static String _dateString(DateTime d) => '${d.year}-${d.month}-${d.day}';
}

// ------------------------------
// MAIN APP ENTRY
// ------------------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await QuotesManager.ensureQuotesForToday();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeModel()),
      ChangeNotifierProvider(create: (_) => JournalModel()),
      ChangeNotifierProvider(create: (_) => FocusModel()),
    ],
    child: const LockinApp(),
  ));
}

// ------------------------------
// Root Widget
// ------------------------------
class LockinApp extends StatelessWidget {
  const LockinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
      builder: (context, theme, _) {
        final scheme = ColorScheme.fromSeed(seedColor: theme.accent);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'LockIn',
          theme: ThemeData(
            fontFamily: 'Inter',
            colorScheme: scheme,
            useMaterial3: true,
            appBarTheme: AppBarTheme(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
            ),
          ),
          home: const ShellScreen(),
        );
      },
    );
  }
}

// ------------------------------
// Shell with 5 Bottom Tabs
// ------------------------------
class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    FocusTimerScreen(),
    StatsScreen(),
    JournalScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (v) => setState(() => _index = v),
        selectedItemColor: Theme.of(context).colorScheme.primary,
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

// ------------------------------
// Home Screen
// ------------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _quote = '';
  String _greeting = 'Hey';
  String _todayFocus = '0m';
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadQuoteAndStats();
  }

  Future<void> _loadQuoteAndStats() async {
    final quote = await QuotesManager.getQuoteForNow();
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = (hour < 12) ? 'Good morning,' : (hour < 18) ? 'Good afternoon,' : 'Good evening,';
    final focus = Provider.of<FocusModel>(context, listen: false);
    await focus.refreshForDate(DateTime.now());
    setState(() {
      _quote = quote;
      _greeting = greeting;
      _todayFocus = '${focus.todayMinutes}m';
      _streak = focus.streak;
    });
  }

  void _startFocus() {
    // navigate to Focus tab
    final shell = context.findAncestorStateOfType<_ShellScreenState>();
    shell?.setState(() => shell._index = 1);
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final name = "David"; // you can change to read from user prefs later
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
                Text('$_greeting $name', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                    onPressed: () {
                      final shell = context.findAncestorStateOfType<_ShellScreenState>();
                      shell?.setState(() => shell._index = 4);
                    },
                    icon: const Icon(Icons.settings_outlined))
              ],
            ),
            const SizedBox(height: 6),
            Text('ready to lock in?', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: _startFocus,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [Colors.white, accent.withOpacity(0.12)]),
                    border: Border.all(color: accent, width: 6),
                  ),
                  child: Center(
                    child: Text('Start\nFocus\nSession', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, color: accent, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Center(child: Text("Today's Focus", style: TextStyle(color: Colors.grey[700]))),
            const SizedBox(height: 8),
            Center(child: Text(_todayFocus, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.local_fire_department_outlined, size: 18),
              const SizedBox(width: 8),
              Text('Day ${_streak} of Focus Streak', style: TextStyle(color: Colors.grey[700])),
            ]),
            const SizedBox(height: 20),
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('Motivation', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: accent.withOpacity(0.06), borderRadius: BorderRadius.circular(12)),
              child: Text(_quote, style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------
// Focus Timer Screen (25 min default)
// ------------------------------
class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});
  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  Duration _remaining = const Duration(minutes: 25);
  bool _running = false;
  Ticker? _ticker;

  void _tick(Duration _) {
    if (!_running) return;
    setState(() {
      _remaining -= const Duration(seconds: 1);
      if (_remaining <= Duration.zero) {
        _remaining = Duration.zero;
        _running = false;
        _ticker?.stop();
        _onSessionComplete();
      }
    });
  }

  Future<void> _onSessionComplete() async {
    // Add minutes to stats (rounded to nearest minute)
    final minutes = 25;
    final focus = Provider.of<FocusModel>(context, listen: false);
    await focus.addMinutes(minutes);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Focus session completed — well done!')));
  }

  void _startTicker() {
    _ticker ??= Ticker(_tick)..start();
  }

  void _stopTicker() {
    _ticker?.stop();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Center(child: Text('Focus', style: Theme.of(context).textTheme.headlineSmall)),
          const SizedBox(height: 24),
          Text(_format(_remaining), style: TextStyle(fontSize: 64, color: accent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _running = !_running;
                  if (_running) _startTicker(); else _stopTicker();
                });
              },
              child: Text(_running ? 'Pause' : 'Start'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: accent, side: BorderSide(color: accent)),
              onPressed: () {
                setState(() {
                  _remaining = const Duration(minutes: 25);
                  _running = false;
                  _stopTicker();
                });
              },
              child: const Text('End'),
            ),
            const SizedBox(width: 12),
            OutlinedButton(onPressed: () => setState(() => _remaining += const Duration(minutes: 5)), child: const Text('Extend')),
          ]),
          const SizedBox(height: 30),
          Expanded(child: Container(width: double.infinity, decoration: BoxDecoration(color: accent.withOpacity(0.08), borderRadius: const BorderRadius.vertical(top: Radius.circular(24))), child: const Center(child: Text('Focus background wave / animation placeholder'))))
        ],
      ),
    );
  }
}

// ------------------------------
// Ticker helper
// ------------------------------
class Ticker {
  final void Function(Duration) _tick;
  bool _active = false;
  Duration _elapsed = Duration.zero;
  Ticker(this._tick);

  void start() async {
    _active = true;
    while (_active) {
      await Future.delayed(const Duration(seconds: 1));
      if (_active) {
        _elapsed += const Duration(seconds: 1);
        _tick(_elapsed);
      }
    }
  }

  void stop() => _active = false;
  void dispose() => _active = false;
}

// ------------------------------
// Stats Screen
// ------------------------------
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final bars = [0.4, 0.5, 0.8, 0.7, 0.9, 0.6, 0.5];
    final focus = Provider.of<FocusModel>(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(children: [
          Text("Weekly Focus", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 18),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(7, (i) {
            return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              Container(width: 18, height: 120 * bars[i], decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(6))),
              const SizedBox(height: 6),
              Text(['M', 'T', 'W', 'T', 'F', 'S', 'S'][i]),
            ]);
          })),
          const SizedBox(height: 24),
          Text("Today's Focus: ${focus.todayMinutes}m", style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text("Streak: ${focus.streak} days", style: const TextStyle(fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

// ------------------------------
// Journal Screen
// ------------------------------
class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<JournalModel>(builder: (context, j, _) {
      final accent = Theme.of(context).colorScheme.primary;
      return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openDialog(context),
          child: const Icon(Icons.add),
        ),
        body: SafeArea(
          child: j.items.isEmpty
              ? const Center(child: Text("No journal entries yet"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: j.items.length,
                  itemBuilder: (context, i) {
                    final e = j.items[i];
                    return Card(
                      child: ListTile(
                        title: Text(e.text),
                        subtitle: Text("${e.date.toLocal()} • ${e.minutes}m focus"),
                        trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => j.remove(e.id)),
                      ),
                    );
                  }),
        ),
      );
    });
  }

  void _openDialog(BuildContext context) {
    final c = TextEditingController();
    int minutes = 25;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("New Journal Entry"),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: c, maxLines: 3, decoration: const InputDecoration(hintText: "Your thoughts")),
          const SizedBox(height: 10),
          Row(children: [
            const Text("Minutes: "),
            StatefulBuilder(builder: (bc, setState) {
              return DropdownButton<int>(value: minutes, onChanged: (v) => setState(() => minutes = v ?? minutes), items: const [
                DropdownMenuItem(value: 15, child: Text("15")),
                DropdownMenuItem(value: 25, child: Text("25")),
                DropdownMenuItem(value: 45, child: Text("45")),
                DropdownMenuItem(value: 60, child: Text("60")),
              ]);
            })
          ])
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(onPressed: () {
            final txt = c.text.trim();
            if (txt.isNotEmpty) {
              final e = JournalEntry(id: DateTime.now().millisecondsSinceEpoch.toString(), text: txt, date: DateTime.now(), minutes: minutes);
              Provider.of<JournalModel>(context, listen: false).add(e);
            }
            Navigator.pop(ctx);
          }, child: const Text("Add"))
        ],
      ),
    );
  }
}

// ------------------------------
// Settings Screen (Color Picker)
// ------------------------------
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeModel>(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Settings", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // Color preview circle
          Center(
            child: Container(width: 70, height: 70, decoration: BoxDecoration(color: theme.accent, shape: BoxShape.circle, border: Border.all(color: Colors.black12, width: 2))),
          ),
          const SizedBox(height: 25),
          const Text("Choose Accent Color"),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.color_lens_outlined),
            label: const Text("Open Color Picker"),
            onPressed: () {
              showDialog(context: context, builder: (ctx) {
                Color tempColor = theme.accent;
                return AlertDialog(title: const Text("Pick Your Color"), content: SingleChildScrollView(child: ColorPicker(pickerColor: tempColor, onColorChanged: (c) => tempColor = c, pickerAreaHeightPercent: 0.8)), actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                  TextButton(onPressed: () { theme.setAccent(tempColor); Navigator.pop(ctx); }, child: const Text("Save")),
                ]);
              });
            },
          ),
          const Spacer(),
          Center(child: Text("LockIn v1.0", style: TextStyle(color: Colors.grey[600]))),
        ]),
      ),
    );
  }
}
