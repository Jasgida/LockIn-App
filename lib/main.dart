import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/theme_model.dart';
import 'providers/focus_model.dart';
import 'providers/journal_model.dart';
import 'screens/shell_screen.dart';
import 'utils/quotes_manager.dart';

// ✅ Add this global key
final GlobalKey<ShellScreenState> shellKey = GlobalKey<ShellScreenState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await QuotesManager.ensureQuotesForToday();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeModel()),
      ChangeNotifierProvider(create: (_) => JournalModel()),
      ChangeNotifierProvider(create: (_) => FocusModel()),
    ],
    child: const LockInApp(),
  ));
}

class LockInApp extends StatelessWidget {
  const LockInApp({super.key});

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
          // ✅ Pass the key here
          home: ShellScreen(key: shellKey),
        );
      },
    );
  }
}
