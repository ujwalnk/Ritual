import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
          GestureDetector(
            onDoubleTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: (data["ritual"].background == Constants.noBackground)
                      ? const AssetImage("assets/illustrations/ritual.jpg")
                      : (!data["ritual"]
                              .background
                              .toString()
                              .contains("assets/illustrations")
                          ? FileImage(File(data['ritual'].background))
                          : AssetImage(data['ritual'].background)
                              as ImageProvider),
                  fit: BoxFit.cover,
                ),
              ),
              height: 200,
            ),
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
          // const SizedBox(height: 10),
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
            // Two day rule coloring
            color: SharedPreferencesManager().getTwoDayRule()
                ? (((ritual.checkedOn?.difference(DateTime.now()).inDays ??
                            double.infinity) >=
                        2)
                    ? Colors.amber[50]
                    : Colors.white)
                : Colors.white,
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            elevation: 0,
            child: Slidable(
              key: Key(ritual.key.toString()),
              startActionPane: ActionPane(
                  motion: const BehindMotion(),
                  dismissible: DismissiblePane(onDismissed: () {
                    deleteHabit(ritual);
                  }),
                  children: [
                    SlidableAction(
                      onPressed: ((context) => deleteHabit(ritual)),
                      backgroundColor: const Color.fromARGB(189, 229, 198, 190),
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
                      backgroundColor: const Color.fromARGB(190, 223, 226, 230),
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
                              ? CustomIcons.rHabit
                              : (ritual.type == "habit/${Constants.typeDHabit}"
                                  ? CustomIcons.dHabit
                                  : (ritual.type ==
                                          "habit/${Constants.typeSHabit}"
                                      ? CustomIcons.sHabit
                                      : CustomIcons.tHabit)),
                          color: ritual.priority == 1
                              ? const Color.fromARGB(75, 244, 67, 54)
                              : (ritual.priority == 2
                                  ? const Color.fromARGB(75, 255, 153, 0)
                                  : (ritual.priority == 3
                                      ? const Color.fromARGB(75, 33, 149, 243)
                                      : const Color.fromARGB(75, 0, 0, 0))),
                          size: 16,
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
                                color: SharedPreferencesManager()
                                            .getColorizeHabitText ==
                                        true
                                    ? (ritual.priority == 1
                                        ? Colors.red
                                        : (ritual.priority == 2
                                            ? Colors.orange
                                            : (ritual.priority == 3
                                                ? Colors.blue
                                                : Colors.black)))
                                    : Colors.black,
                                fontFamily: "NotoSans-Light",
                              ),
                            ),
                            Text(
                                ritual.stackTime
                                    ? " ${num.parse(((ritual.initValue ?? 0) * pow((1 + 0.01), (DateTime.now().difference(ritual.createdOn!).inDays))).toStringAsFixed(2))} Min"
                                    : " ${ritual.duration} Min",
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontFamily: "NotoSans-Light",
                                ))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Check / Cross Icon on habit complete
                Align(
                    // top: 20,
                    // left: 350,
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 32.0),
                      child: Stack(children: [
                        Visibility(
                          // On ritual check show check if icon is not a dHabit, cross mark if it's dHabit
                          visible: ritual.complete == 1,
                          child: (ritual.type?.contains("dHabit") ?? false)
                              ? const Icon(CustomIcons.crossCircle,
                                  color: Colors.red)
                              : const Icon(CustomIcons.checkCircle,
                                  color: Colors.green),
                        ),
                        Visibility(
                          // On habit notCheck, show count for sHabits
                          visible: ritual.complete == 0 &&
                              ritual.type!.contains(Constants.typeSHabit) &&
                              !ritual.stackTime,
                          child: Text(
                              "${num.parse(((ritual.initValue ?? 0) * pow((1 + 0.01), (DateTime.now().difference(ritual.createdOn!).inDays))).toStringAsFixed(2))}",
                              style: const TextStyle(
                                  fontFamily: "NotoSans-Light", fontSize: 20)),
                        ),
                      ]),
                    )),

                // Timer Icon for non Stacked Habits
                Visibility(
                  visible: ritual.complete == 0 &&
                      !((ritual.type!.contains(Constants.typeSHabit) &&
                              !ritual.stackTime) ||
                          ritual.type!.contains(Constants.typeDHabit)) &&
                      (ritual.duration != 0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: IconButton(
                          icon: const Icon(Icons.timer,
                              color: Color.fromARGB(75, 158, 158, 158)),
                          onPressed: () {
                            debugPrint("Before navigator: ${ritual.duration}");
                            if (ritual.type == Constants.typeSHabit) {
                              ritual.duration = ((ritual.initValue ?? 0) *
                                  pow(
                                      (1 + 0.01),
                                      (DateTime.now()
                                          .difference(ritual.createdOn!)
                                          .inDays))) as double?;
                              ritual.save();
                            }
                            Navigator.pushNamed(context, "/timer", arguments: {
                              "ritual": ritual,
                            });
                            debugPrint("After navigator: ${ritual.duration}");
                          }),
                    ),
                  ),
                )
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
