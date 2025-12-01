import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

// Providers
import 'providers/theme_model.dart';
import 'providers/focus_model.dart';
import 'providers/journal_model.dart';

// Screens
import 'screens/splash_decider.dart';

// Utils
import 'utils/quotes_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Prepare today's quote
  await QuotesManager.ensureQuotesForToday();

  // Run app with all providers
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeModel()),
        ChangeNotifierProvider(create: (_) => JournalModel()),
        ChangeNotifierProvider(create: (_) => FocusModel()),
      ],
      child: const LockInApp(),
    ),
  );
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

          // 🔥 NEW AUTO NAVIGATION SYSTEM
          home: const SplashDecider(),
        );
      },
    );
  }
}
