import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/journal_model.dart';
import '../models/journal_entry.dart';
import 'package:intl/intl.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<JournalModel>(
      builder: (context, j, _) {
        final accent = Theme.of(context).colorScheme.primary;

        return Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: accent,
            onPressed: () => _openDialog(context),
            child: const Icon(Icons.add),
          ),

          body: SafeArea(
            child: j.items.isEmpty
                ? const Center(
                    child: Text(
                      "No journal entries yet",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: j.items.length,
                    itemBuilder: (context, i) {
                      final e = j.items[i];

                      return Card(
                        elevation: 1.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(e.text),
                          subtitle: Text(
                            "${DateFormat('EEE, MMM d • h:mm a').format(e.date)} • ${e.minutes}m focus",
                            style: TextStyle(color: Colors.grey[700], fontSize: 13),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => j.remove(e.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  void _openDialog(BuildContext context) {
    final c = TextEditingController();
    int minutes = 25;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),

        title: const Text(
          "New Journal Entry",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),

        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: c,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Your thoughts...",
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                const Text("Minutes: "),
                const SizedBox(width: 12),
                StatefulBuilder(
                  builder: (bc, setState) {
                    return DropdownButton<int>(
                      value: minutes,
                      onChanged: (v) => setState(() => minutes = v ?? minutes),
                      items: const [
                        DropdownMenuItem(value: 15, child: Text("15")),
                        DropdownMenuItem(value: 25, child: Text("25")),
                        DropdownMenuItem(value: 45, child: Text("45")),
                        DropdownMenuItem(value: 60, child: Text("60")),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),

          TextButton(
            onPressed: () {
              final txt = c.text.trim();

              if (txt.isNotEmpty) {
                final entry = JournalEntry(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  text: txt,
                  date: DateTime.now(),
                  minutes: minutes,
                );

                Provider.of<JournalModel>(context, listen: false).add(entry);
              }

              Navigator.pop(ctx);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
