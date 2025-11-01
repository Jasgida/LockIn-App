import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/focus_model.dart';

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
    final minutes = 25;
    final focus = Provider.of<FocusModel>(context, listen: false);
    await focus.addMinutes(minutes);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Focus session completed — well done!')));
    }
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
