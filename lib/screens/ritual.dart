import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Database
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ritual/model/ritual.dart';

// Services
import 'package:ritual/services/boxes.dart';
import 'package:ritual/services/constants.dart';
import 'package:ritual/services/ritual_icons.dart';
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
                image: (data["ritual"].background == Constants.noBackground)
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
            valueListenable: Boxes.getBox().listenable(),
            builder: (context, box, _) {
              habitCount = 0;
              final contents = box.values.toList().cast<Ritual>();
              var rituals = <Ritual>[];
              for (var ritual in contents) {
                if ((ritual.type?.contains("habit") ?? false) &&
                    ritual.url.contains(data['ritual'].url)) {
                  rituals.add(ritual);
                }
              }

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
            // Set to complete and expire the next day
            ritual.complete = 1;
            ritual.checkedOn = DateTime.now();
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
          height: 70,
          child: Card(
            color: Colors.white,
            elevation: 0,
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
                      borderRadius: BorderRadius.zero,
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
              child: Stack(children: [
                Container(
                  height: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Icon(
                          (ritual.type == "habit/${Constants.typeRHabit}")
                              ? CustomIcons.puzzle
                              : (ritual.type == "habit/${Constants.typeDHabit}"
                                  ? CustomIcons.puzzleOutline
                                  : (ritual.type ==
                                          "habit/${Constants.type1Habit}"
                                      ? CustomIcons.circle1
                                      : CustomIcons.hourglass)),
                          color: ritual.priority == 1
                              ? Colors.red
                              : (ritual.priority == 2
                                  ? Colors.orange
                                  : (ritual.priority == 3
                                      ? Colors.blue
                                      : Colors.black)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
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
                            Text(
                              " ${ritual.duration?.inMinutes} Min",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontFamily: "NotoSans-Light",
                              )
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                    top: 20,
                    left: 350,
                    child: Visibility(
                      // On ritual check show check if icon is not a dHabit, cross mark if it's dHabit
                      visible: ritual.complete == 1,
                      child: (ritual.type?.contains("dHabit") ?? false)
                          ? const Icon(CustomIcons.crossCircle,
                              color: Colors.red)
                          : const Icon(CustomIcons.checkCircle,
                              color: Colors.green),
                    )),
              ]),
            ),
          ),
        ),
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
