import 'package:flutter/material.dart';
import 'package:ritual/model/ritual.dart';
import 'package:ritual/screens/ritual.dart';
import 'package:ritual/services/boxes.dart';

class RitualSort extends StatefulWidget {
  const RitualSort({super.key});

  @override
  State<RitualSort> createState() => _RitualSortState();
}

class _RitualSortState extends State<RitualSort> {
  
  @override
  Widget build(BuildContext context) {
    // Data from caller page
    Map data = ModalRoute.of(context)?.settings.arguments as Map;

    final List content = Boxes.getBox().values.toList().cast<Ritual>();

    List<Ritual> habitsOfRitual = [];

    for (Ritual r in content) {
      if (r.url.contains(data['ritual'].url) && r.type != "ritual") {
        habitsOfRitual.add(r);
      }
    }

    habitsOfRitual.sort((a, b) => a.position!.compareTo(b.position!));


    return Scaffold(
        appBar: AppBar(
          title: Text(
              "Sort ${data['ritual'].url.toString().replaceFirst("/", "")}"),
          centerTitle: true,
        ),
        body: ReorderableListView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          children: <Widget>[
            for (int index = 0; index < habitsOfRitual.length; index += 1)
              ListTile(
                key: Key('$index'),
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(Icons.drag_indicator_sharp),
                    const SizedBox(width: 10),
                    Text(habitsOfRitual[index]
                        .url
                        .replaceFirst("${data['ritual'].url.toString()}/", "")),
                  ],
                ),
              ),
          ],
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final Ritual item = habitsOfRitual.removeAt(oldIndex);
              habitsOfRitual.insert(newIndex, item);

              // Update positions
              for (int i = 0; i < habitsOfRitual.length; i++) {
                habitsOfRitual[i].position = i;
              }

              debugPrint("Reordering Item @$oldIndex to $newIndex");
            });
          },
        ));
  }
}
