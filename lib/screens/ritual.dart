import 'package:flutter/material.dart';
import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:ritual/services/boxes.dart';
import 'package:ritual/model/ritual.dart';

class Rituals extends StatefulWidget {
  const Rituals({super.key});

  @override
  State<Rituals> createState() => _RitualsState();
}

class _RitualsState extends State<Rituals> {
  @override
  Widget build(BuildContext context) {
    // Data from caller page
    Map data = ModalRoute.of(context)?.settings.arguments as Map;

    return Scaffold(
      // Status bar transparent with body
      extendBodyBehindAppBar: true,

      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(File(data['background'])),
                fit: BoxFit.cover,
              ),
            ),
            height: 200,
          ),
          Container(
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      // Navigate back when the back arrow is pressed
                      Navigator.pop(context);
                    },
                  ),
                  // TODO: Messy fix for aligning heading
                  IconButton(
                    icon: const Icon(Icons.back_hand),
                    onPressed: () {},
                    color: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        data['ritual'].toString().replaceFirst('/', ""),
                        style: const TextStyle(
                          color: Colors.black,
                          fontFamily: "NotoSans-Light",
                          fontSize: 32,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: Edit the ritual
                      Navigator.pushNamed(context, "/commit/ritual",
                          arguments: {
                            "uri": data["ritual"],
                            "mode": "edit",
                            "time": Boxes.getBox()
                                .values
                                .toList()
                                .where(
                                    (element) => element.url == data['ritual'])
                                .first
                                .time
                          });
                    },
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/commit/habit",
                          arguments: {"uri": data["ritual"], "mode": "new"});
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<Box<Ritual>>(
            valueListenable: Boxes.getBox().listenable(),
            builder: (context, box, _) {
              final contents = box.values.toList().cast<Ritual>();
              var rituals = <Ritual>[];
              for (var ritual in contents) {
                if (ritual.type == "habit" &&
                    ritual.url.contains(data['ritual'])) {
                  // ritual.url =
                  // ritual.url.toString().replaceAll(data['ritual'], "");
                  rituals.add(ritual);
                }
                debugPrint("Ritual: ${ritual.url}");
              }
              debugPrint("Rituals: ${rituals.length}");
              return buildContent(rituals);
            },
          ),
        ],
      ),
    );
  }

  /// Build the list of cards
  Widget buildContent(List<Ritual> content) {
    if (content.isEmpty) {
      // Return a message
      return const Center(
        child: Text(
          'Tap the + icon to add a new habit',
          style: TextStyle(fontSize: 18),
        ),
      );
    } else {
      return SlidableAutoCloseBehavior(
        closeWhenOpened: true,
        child: Expanded(
          child: ListView.builder(
            itemCount: content.length,
            itemBuilder: (BuildContext context, int index) {
              final ritual = content[index];
              return buildCard(context, ritual);
            },
          ),
        ),
      );
    }
  }

  /// Build card for each habit
  Widget buildCard(
    BuildContext context,
    Ritual ritual,
  ) {
    debugPrint("@ritual: Building card for: ${ritual.url}");
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        // Mark the habit done
        if (ritual.complete == 0) {
          setState(() {
            ritual.complete = 1;
            ritual.save();
          });
        } else {
          // Don't uncheck habits
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Trying to uncheck?'),
                content: const Text(
                    'Commitments fullfilled; Why unmark accomplishments?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      // Close the dialog
                      Navigator.of(context).pop();
                    },
                    child: const Text('Makes Sense'),
                  ),
                ],
              );
            },
          );
        }
      },
      child: SizedBox(
        height: 100,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          color: Colors.white,
          elevation: 1,
          child: Slidable(
            key: UniqueKey(),
            startActionPane: ActionPane(
                motion: const DrawerMotion(),
                dismissible: DismissiblePane(onDismissed: () {
                  debugPrint("@ritual: Calling Delete");
                  deleteHabit(ritual);
                }),
                children: [
                  SlidableAction(
                    onPressed: ((context) => editHabit()),
                    backgroundColor: const Color.fromRGBO(229, 115, 115, 1),
                    icon: Icons.delete_forever,
                    label: "Delete",
                  ),
                  SlidableAction(
                    onPressed: ((context) => Navigator.pushNamed(
                        context, "/commit/habit",
                        arguments: {"mode": "edit", "uri":ritual.url, "ritual": ritual})),
                    backgroundColor: const Color.fromRGBO(144, 202, 249, 1),
                    icon: Icons.edit,
                    label: "Edit",
                  ),
                ]),
            child: Center(
              child: Text(
                ritual.url.split("/").last,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 23,
                  color: Colors.black,
                  fontFamily: "NotoSans-Light",
                  decoration: ritual.complete == 1
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Delete the current ritual & habits
  void deleteHabit(Ritual r) {
    Boxes.getBox().delete(r.key);
    Boxes.getBox().flush();
    setState(() => {});
  }

  void editHabit() {}
}
