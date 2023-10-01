import 'package:flutter/material.dart';
import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:ritual/services/boxes.dart';
import 'package:ritual/model/ritual.dart';
import 'package:ritual/services/shared_prefs.dart';

class Rituals extends StatefulWidget {
  const Rituals({super.key});

  @override
  State<Rituals> createState() => _RitualsState();
}

class _RitualsState extends State<Rituals> {
  int habitCount = 0;

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
                image: (data["ritual"].background == "default")
                    ? const AssetImage("assets/illustrations/ritual.jpg")
                        as ImageProvider
                    : FileImage(File(data['background'])),
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
                    icon: const Icon(Icons.sort),
                    onPressed: () {
                      Navigator.pushNamed(context, "/sort/ritual",
                          arguments: {"ritual": data["ritual"]});
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        data['ritual'].url.toString().replaceFirst('/', ""),
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
                      Navigator.pushNamed(context, "/commit/habit", arguments: {
                        "uri": data["ritual"].url,
                        "mode": "new",
                        "position": habitCount
                      });
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<Box<Ritual>>(
            valueListenable: Boxes.getBox().listenable(keys: Ritual().key),
            builder: (context, box, _) {
              habitCount = 0;
              final contents = box.values.toList().cast<Ritual>();
              var rituals = <Ritual>[];
              for (var ritual in contents) {
                if (ritual.type == "habit" &&
                    ritual.url.contains(data['ritual'].url)) {
                  rituals.add(ritual);
                }
                debugPrint(
                    "Working on Ritual: ${ritual.url} @ ${ritual.position}");
              }
              debugPrint("Habits: ${rituals.length}");

              // Sort rituals based on the 'position' field
              rituals.sort((a, b) => a.position!.compareTo(b.position!));

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
    habitCount++;

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
      child: Stack(children: [
        SizedBox(
          height: 100,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            color: Colors.white,
            elevation: 1,
            child: Slidable(
              key: Key(ritual.key.toString()),
              startActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  dismissible: DismissiblePane(onDismissed: () {
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
                              context, "/commit/habit", arguments: {
                            "mode": "edit",
                            "uri": ritual.url,
                            "ritual": ritual
                          })),
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
                    color: ritual.priority == 1
                        ? Colors.red
                        : (ritual.priority == 2
                            ? Colors.orange
                            : (ritual.priority == 3
                                ? Colors.blue
                                : Colors.black)),
                    fontFamily: "NotoSans-Light",
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 47,
          left: 51.7, // (cardsize - width) / 2
          child: Visibility(
            visible: ritual.complete == 1,
            child: SvgPicture.asset(
              "assets/strikethrough/style-${SharedPreferencesManager().getStrikethroughStyle()}.svg",
              width: 300
            ),
          ),
        )
      ]),
    );
  }

  /// Delete the current ritual & habits
  void deleteHabit(Ritual r) {
    Boxes.getBox().delete(r.key);
    Boxes.getBox().flush();
  }

  void editHabit() {}
}
