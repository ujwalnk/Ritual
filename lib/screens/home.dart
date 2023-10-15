import 'dart:io';

import 'package:flutter/material.dart';

// Hive database packages
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ritual/model/ritual.dart';

// Services
import 'package:ritual/services/boxes.dart';
import 'package:ritual/services/constants.dart';
import 'package:ritual/services/ritual_icons.dart';
import 'package:ritual/services/shared_prefs.dart';
import 'package:ritual/services/widgets/fab.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const String typeRitual = "ritual";
  static const String typeSprint = "sprint";
  static const String typeHLight = "highlight";

  bool hideSprints = true;
  bool hideHighlights = true;

  @override
  Widget build(BuildContext context) {
    ExpandableFab fab = ExpandableFab(
        sprint: SharedPreferencesManager().getShowSprints(),
        highlight: SharedPreferencesManager().getShowHighlight());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          (SharedPreferencesManager().getShowHighlight() ||
                  SharedPreferencesManager().getShowSprints())
              ? "Home"
              : "Rituals",
          style: const TextStyle(
            // color: Colors.white,
            fontFamily: "NotoSans-Light",
          ),
        ),
        backgroundColor: Constants.primaryColor,
        shadowColor: Constants.primaryAccent,
        elevation: 2,
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.settings,
              // color: Colors.white,
            ),
            onPressed: () async {
              await Navigator.pushNamed(context, '/settings');
              // SetState for changes to reflect
              setState(() {});
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
              visible: SharedPreferencesManager().getShowHighlight(),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  hideHighlights = !hideHighlights;
                  setState(() {});
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(17.0, 16.0, 0, 16.0),
                  child: Stack(
                    children: [
                      Text(
                        "Highlights",
                        style: TextStyle(
                            fontSize: 22,
                            fontFamily: "NotoSans-Light",
                            decoration: hideHighlights
                                ? TextDecoration.none
                                : TextDecoration.lineThrough),
                      ),
                      // Don't hide the icon, make it transparent, otherwise GestureDetector won't work
                      Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Icon(CustomIcons.lightbulbOutline,
                                color: hideHighlights ? Constants.primaryAccent.withAlpha(50) : Constants.primaryAccent.withAlpha(0)),
                          ))
                    ],
                  ),
                ),
              ),
            ),
            Visibility(
              visible: SharedPreferencesManager().getShowHighlight() &&
                  hideHighlights,
              child: ValueListenableBuilder<Box<Ritual>>(
                valueListenable: Boxes.getBox().listenable(),
                builder: (context, box, _) {
                  final contents = box.values.toList().cast<Ritual>();
                  var rituals = <Ritual>[];
                  for (var ritual in contents) {
                    if (ritual.type == typeHLight) {
                      rituals.add(ritual);
                    }
                  }
                  // Sort alphabetically
                  rituals.sort((a, b) => a.url.compareTo(b.url));

                  return buildContent(rituals, type: typeHLight);
                },
              ),
            ),
            Visibility(
              visible: SharedPreferencesManager().getShowSprints(),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  hideSprints = !hideSprints;
                  setState(() {});
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(17.0, 16.0, 0, 16.0),
                  child: Stack(children: [
                    Text(
                      "Sprints",
                      style: TextStyle(
                          fontSize: 22,
                          fontFamily: "NotoSans-Light",
                          decoration: hideSprints
                              ? TextDecoration.none
                              : TextDecoration.lineThrough),
                    ),
                    // Don't hide the icon, make it transparent, otherwise GestureDetector won't work
                    Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Icon(CustomIcons.directionsRun,
                                color: hideSprints ? Constants.primaryAccent.withAlpha(50) : Constants.primaryAccent.withAlpha(0))))
                  ]),
                ),
              ),
            ),
            Visibility(
              visible:
                  SharedPreferencesManager().getShowSprints() && hideSprints,
              child: ValueListenableBuilder<Box<Ritual>>(
                valueListenable: Boxes.getBox().listenable(),
                builder: (context, box, _) {
                  final contents = box.values.toList().cast<Ritual>();
                  var rituals = <Ritual>[];
                  for (var ritual in contents) {
                    if (ritual.type == typeSprint) {
                      rituals.add(ritual);
                    }
                  }
                  // Sort by expiry
                  rituals.sort((a, b) => a.expiry!.compareTo(b.expiry!));

                  return buildContent(rituals, type: typeSprint);
                },
              ),
            ),
            Visibility(
              visible: SharedPreferencesManager().getShowHighlight() ||
                  SharedPreferencesManager().getShowSprints(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(17.0, 16.0, 0, 16.0),
                child: Stack(children: [
                    const Text(
                    "Rituals",
                    style:
                        TextStyle(fontSize: 22, fontFamily: "NotoSans-Light"),
                  ),
                  Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Icon(CustomIcons.fire,
                            color: Constants.primaryAccent.withAlpha(50)),
                      ))
                ]),
              ),
            ),
            Visibility(
              visible:
                  ((SharedPreferencesManager().getShowHighlight() == false) &&
                      (SharedPreferencesManager().getShowSprints() == false)),
              child: const SizedBox(height: 20),
            ),
            ValueListenableBuilder<Box<Ritual>>(
              valueListenable: Boxes.getBox().listenable(),
              builder: (context, box, _) {
                final contents = box.values.toList().cast<Ritual>();
                var rituals = <Ritual>[];
                for (var ritual in contents) {
                  if (ritual.type == "ritual") {
                    rituals.add(ritual);
                  }
                }

                // Sort by time
                rituals.sort((a, b) {
                  if (a.time["hour"] != b.time["hour"]) {
                    return a.time["hour"] - b.time["hour"];
                  } else {
                    return a.time["minute"] - b.time["minute"];
                  }
                });

                return buildContent(rituals);
              },
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: fab,
    );
  }

  Widget buildContent(List<Ritual> rituals, {String type = typeRitual}) {
    if (rituals.isEmpty) {
      // Return a message or an empty state widget when there are no rituals.
      return const SizedBox(height: 0, width: 0);
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final ritual in rituals) buildCard(context, ritual, type: type),
        ],
      );
    }
  }

  Widget buildCard(BuildContext context, Ritual ritual,
      {String type = typeRitual}) {
    // Calculate the percentage complete of ritual
    if (type == typeRitual) {
      final rituals = Boxes.getBox().values.toList().cast<Ritual>();

      int habits = 0;
      int complete = 0;

      for (Ritual r in rituals) {
        if (r.url.contains(ritual.url) && (r.type!.contains("habit"))) {
          // Higher priority, higher complete
          if (!r.type!.contains(Constants.typeDHabit)) {
            habits += (5 - r.priority);
          }

          if (r.complete == 1) {
            if (r.type!.contains(Constants.typeDHabit)) {
              habits += (5 - r.priority);
              complete -= (5 - r.priority);
            } else {
              complete += (5 - r.priority);
            }
          }
        }
      }

      ritual.complete =
          complete >= 0 ? ((habits == 0) ? 1 : complete / habits) : 0;
      ritual.save();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(60.0, 0, 5, 0),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (type == typeRitual) {
            Navigator.pushNamed(context, "/rituals", arguments: {
              "background": ritual.background!,
              "ritual": ritual,
            });
          } else {
            // Mark the habit done
            if (ritual.complete == 0) {
              setState(() {
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
          }
        },
        onLongPress: () {
          // Display edit and delete options for highlights & sprints
          Navigator.pushNamed(context, "/commit/${ritual.type}", arguments: {
            "uri": ritual.url,
            "background": ritual.background,
            "mode": "edit",
            "time": ritual.time,
            "expiry": ritual.expiry,
            "ritual": ritual
          });
        },
        child: SizedBox(
          height: 100,
          child: Card(
            color: Colors.transparent,
            elevation: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Stack(
                // Use a Stack to overlay the image and text.
                children: [
                  // Background
                  if (ritual.background != Constants.noBackground)
                    ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        // Set greyscale intensity
                        Colors.grey.withOpacity((1 - ritual.complete)),
                        // Use the saturation blend mode to create greyscale effect
                        BlendMode.saturation,
                      ),
                      child: Image.file(
                        File(ritual.background!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                      ),
                    )
                  else
                    ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        // Set greyscale intensity
                        Colors.grey.withOpacity((1 - ritual.complete)),
                        // Use the saturation blend mode to create greyscale effect
                        BlendMode.saturation,
                      ),
                      child: Image.asset(
                        // "assets/illustrations/$type.jpg",
                        "assets/illustrations/e.jpg",
                        fit: BoxFit.fitHeight,
                        alignment: Alignment.centerRight,
                        width: double.infinity,
                        height: 200,
                      ),
                    ),

                  // Text on top of the image.
                  Positioned(
                    left: 24,
                    top: 8,
                    right: 24,
                    bottom: 8,
                    child: Text(
                      ritual.url.replaceAll("/", ""),
                      maxLines: 2,
                      style: const TextStyle(
                          fontSize: 23,
                          color: Colors.white,
                          fontFamily: "NotoSans-Light"),
                    ),
                  ),

                  // Text to the bottom of the image.
                  Visibility(
                    visible: type == typeRitual,
                    child: Positioned(
                      left: 24,
                      top: 48,
                      right: 24,
                      bottom: 8,
                      child: Text(
                        "${ritual.time['hour'] > 12 ? ritual.time['hour'] - 12 : ritual.time['hour']}:${ritual.time['minute'] < 10 ? '0${ritual.time['minute']}' : ritual.time['minute']} ${ritual.time['hour'] >= 12 ? "PM" : "AM"}",
                        maxLines: 2,
                        style: const TextStyle(
                            fontSize: 23,
                            color: Colors.white,
                            fontFamily: "NotoSans-Light"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
