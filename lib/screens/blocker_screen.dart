// lib/screens/blocker_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/blocker_provider.dart';
import '../providers/theme_model.dart';

class BlockerScreen extends StatelessWidget {
  const BlockerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeModel>(context);
    final accent = theme.accent;

    return ChangeNotifierProvider(
      create: (_) => BlockerProvider(),
      child: Consumer<BlockerProvider>(
        builder: (context, blocker, _) {
          if (blocker.isLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('App Blocker'),
              backgroundColor: accent,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            body: RefreshIndicator(
              onRefresh: blocker.loadEverything,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: blocker.allApps.length,
                itemBuilder: (context, i) {
                  final app = blocker.allApps[i];
                  final blocked = blocker.isBlocked(app.packageName);
                  final minutes = blocker.todayUsage[app.packageName] ?? 0;

                  return Card(
                    color: blocked ? Colors.red.shade50 : null,
                    elevation: blocked ? 6 : 2,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: blocked ? Colors.red : accent,
                        child: Text(app.name[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(app.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text("$minutes min today"),
                      trailing: Switch(
                        value: blocked,
                        activeColor: Colors.red,
                        onChanged: (_) => blocker.toggleBlock(app),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}