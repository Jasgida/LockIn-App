import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart'; // ✅ Required for Ticker
import 'package:provider/provider.dart';
import '../providers/focus_model.dart';

class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen>
    with SingleTickerProviderStateMixin {
  Duration _remaining = const Duration(minutes: 25);
  bool _running = false;
  late Ticker _ticker;

  @override
  void initState() {
    super.initState();

    _ticker = createTicker((_) {
      if (!_running) return;

      setState(() {
        _remaining -= const Duration(seconds: 1);

        if (_remaining <= Duration.zero) {
          _remaining = Duration.zero;
          _running = false;
          _ticker.stop();
          _onSessionComplete();
        }
      });
    });
  }

  Future<void> _onSessionComplete() async {
    final focus = Provider.of<FocusModel>(context, listen: false);
    await focus.addMinutes(25);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Focus session completed — well done!')),
      );
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
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
          Center(
            child: Text(
              'Focus',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 24),

          /// Timer Text
          Text(
            _format(_remaining),
            style: TextStyle(
              fontSize: 64,
              color: accent,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          /// Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _running = !_running;
                    if (_running) {
                      _ticker.start();
                    } else {
                      _ticker.stop();
                    }
                  });
                },
                child: Text(_running ? 'Pause' : 'Start'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: accent,
                  side: BorderSide(color: accent),
                ),
                onPressed: () {
                  setState(() {
                    _remaining = const Duration(minutes: 25);
                    _running = false;
                    _ticker.stop();
                  });
                },
                child: const Text('End'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _remaining += const Duration(minutes: 5);
                  });
                },
                child: const Text('Extend'),
              ),
            ],
          ),

          const SizedBox(height: 30),

          /// Background Placeholder
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.08),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: const Center(
                child: Text('Focus background wave / animation placeholder'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
