import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'global_keys.dart'; // ✅ Import your global shellKey
import 'providers/theme_model.dart';
import 'providers/focus_model.dart';
import 'providers/journal_model.dart';
import 'screens/shell_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'utils/quotes_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase correctly for all platforms
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Prepare daily quotes before app starts
  await QuotesManager.ensureQuotesForToday();

  // ✅ Run the main app with all providers
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

          // ✅ Start with splash screen instead of StreamBuilder
          // Splash will automatically route to the right page
          home: const SplashScreen(),
        );
      },
    );
  }
}
