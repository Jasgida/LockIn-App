import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/focus_model.dart';

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
