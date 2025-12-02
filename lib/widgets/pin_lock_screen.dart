// lib/widgets/pin_lock_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinLockScreen extends StatefulWidget {
  final VoidCallback onCorrectPin;
  final VoidCallback onWrongPin;

  const PinLockScreen({required this.onCorrectPin, required this.onWrongPin, super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> with SingleTickerProviderStateMixin {
  String input = "";
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  void _onKey(String key) async {
    setState(() => input += key);
    if (input.length == 4) {
      final prefs = await SharedPreferences.getInstance();
      final correct = prefs.getString('lockin_pin') ?? "1234";

      if (input == correct) {
        widget.onCorrectPin();
      } else {
        widget.onWrongPin();
        _controller.forward().then((_) => _controller.reverse());
        setState(() => input = "");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_controller.value * 20, 0),
          child: Material(
            color: Colors.black.withOpacity(0.98),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 80, color: Colors.white),
                  const SizedBox(height: 30),
                  const Text("Enter PIN to unlock", style: TextStyle(color: Colors.white, fontSize: 22)),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 20, height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < input.length ? Colors.white : Colors.grey[800],
                      ),
                    )),
                  ),
                  const SizedBox(height: 50),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    padding: const EdgeInsets.all(40),
                    children: [
                      for (int i = 1; i <= 9; i++)
                        _keyButton(i.toString()),
                      const SizedBox(width: 1),
                      _keyButton('0'),
                      IconButton(
                        icon: const Icon(Icons.backspace, color: Colors.white),
                        onPressed: () => setState(() => input = input.isNotEmpty ? input.substring(0, input.length - 1) : ""),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _keyButton(String text) {
    return GestureDetector(
      onTap: () => _onKey(text),
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white24),
        child: Center(child: Text(text, style: const TextStyle(fontSize: 28, color: Colors.white))),
      ),
    );
  }
}