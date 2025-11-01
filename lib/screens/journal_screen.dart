import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/journal_model.dart';
import '../models/journal_entry.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<JournalModel>(builder: (context, j, _) {
      final accent = Theme.of(context).colorScheme.primary;
      return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => _openDialog(context),
          child: const Icon(Icons.add),
        ),
        body: SafeArea(
          child: j.items.isEmpty
              ? const Center(child: Text("No journal entries yet"))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: j.items.length,
                  itemBuilder: (context, i) {
                    final e = j.items[i];
                    return Card(
                      child: ListTile(
                        title: Text(e.text),
                        subtitle: Text("${e.date.toLocal()} • ${e.minutes}m focus"),
                        trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => j.remove(e.id)),
                      ),
                    );
                  }),
        ),
      );
    });
  }

  void _openDialog(BuildContext context) {
    final c = TextEditingController();
    int minutes = 25;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("New Journal Entry"),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: c, maxLines: 3, decoration: const InputDecoration(hintText: "Your thoughts")),
          const SizedBox(height: 10),
          Row(children: [
            const Text("Minutes: "),
            StatefulBuilder(builder: (bc, setState) {
              return DropdownButton<int>(value: minutes, onChanged: (v) => setState(() => minutes = v ?? minutes), items: const [
                DropdownMenuItem(value: 15, child: Text("15")),
                DropdownMenuItem(value: 25, child: Text("25")),
                DropdownMenuItem(value: 45, child: Text("45")),
                DropdownMenuItem(value: 60, child: Text("60")),
              ]);
            })
          ])
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(onPressed: () {
            final txt = c.text.trim();
            if (txt.isNotEmpty) {
              final e = JournalEntry(id: DateTime.now().millisecondsSinceEpoch.toString(), text: txt, date: DateTime.now(), minutes: minutes);
              Provider.of<JournalModel>(context, listen: false).add(e);
            }
            Navigator.pop(ctx);
          }, child: const Text("Add"))
        ],
      ),
    );
  }
}
