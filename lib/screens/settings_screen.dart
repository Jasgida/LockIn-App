import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../providers/theme_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
                return AlertDialog(
                  title: const Text("Pick Your Color"),
                  content: SingleChildScrollView(
                    child: ColorPicker(
                      pickerColor: tempColor,
                      onColorChanged: (c) => tempColor = c,
                      pickerAreaHeightPercent: 0.8,
                      enableAlpha: false,
                      displayThumbColor: true,
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
                    TextButton(onPressed: () {
                      theme.setAccent(tempColor);
                      Navigator.pop(ctx);
                    }, child: const Text("Save")),
                  ],
                );
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
