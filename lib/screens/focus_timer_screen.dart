// lib/screens/focus_timer_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';

class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  final _hoursController = TextEditingController(text: '0');
  final _minutesController = TextEditingController(text: '25');
  final _secondsController = TextEditingController(text: '0');

  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;

  @override
  void dispose() {
    _timer?.cancel();
    _hoursController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  void _startTimer() {
    final hours = int.tryParse(_hoursController.text) ?? 0;
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    final seconds = int.tryParse(_secondsController.text) ?? 0;

    _remainingSeconds = hours * 3600 + minutes * 60 + seconds;

    if (_remainingSeconds <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid time")),
      );
      return;
    }

    setState(() => _isRunning = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _stopTimer();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Focus Timer")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_formatTime(_remainingSeconds), style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            if (!_isRunning) Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TimeField(controller: _hoursController, label: "Hours"),
                const Text(" : ", style: TextStyle(fontSize: 32)),
                _TimeField(controller: _minutesController, label: "Minutes"),
                const Text(" : ", style: TextStyle(fontSize: 32)),
                _TimeField(controller: _secondsController, label: "Seconds"),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 200,
              height: 60,
              child: _isRunning
                  ? ElevatedButton(
                      onPressed: _stopTimer,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text("Stop", style: TextStyle(fontSize: 20)),
                    )
                  : ElevatedButton(
                      onPressed: _startTimer,
                      child: const Text("Start Focus", style: TextStyle(fontSize: 20)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _TimeField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label),
        SizedBox(
          width: 60,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 32),
          ),
        ),
      ],
    );
  }
}