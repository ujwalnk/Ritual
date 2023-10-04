import 'dart:io';

import 'package:flutter/material.dart';

// Hive database packages
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ritual/model/ritual.dart';

// Services
import 'package:ritual/services/boxes.dart';
import 'package:ritual/services/constants.dart';
import 'package:ritual/services/shared_prefs.dart';
import 'package:ritual/services/widgets/fab.dart';
import 'package:ritual/services/colorizer.dart';

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
            color: Colors.white,
            fontFamily: "NotoSans-Light",
          ),
        ),
        backgroundColor: Colors.blue[800],
        shadowColor: Colors.blue[400],
        elevation: 2,
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
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
                onTap: () {
                  hideHighlights = !hideHighlights;
                  setState(() {});
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(17.0, 16.0, 0, 16.0),
                  child: Text(
                    hideHighlights ? "Highlights" : "(Highlights)",
                    style: const TextStyle(
                        fontSize: 22, fontFamily: "NotoSans-Light"),
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
                onTap: () {
                  hideSprints = !hideSprints;
                  setState(() {});
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(17.0, 16.0, 0, 16.0),
                  child: Text(
                    hideSprints ? "Sprints" : "(Sprints)",
                    style: const TextStyle(
                        fontSize: 22, fontFamily: "NotoSans-Light"),
                  ),
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
              child: const Padding(
                padding: EdgeInsets.fromLTRB(17.0, 16.0, 0, 16.0),
                child: Text(
                  "Rituals",
                  style: TextStyle(fontSize: 22, fontFamily: "NotoSans-Light"),
                ),
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
                rituals.sort((a, b) => a.time!.compareTo(b.time!));

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
      return Center(
        child: Text(
          'Tap the + icon to create your first $type',
          style: const TextStyle(fontSize: 18),
        ),
      );
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
    Color? cardTextColor = Colors.pink;

    Future<void> generateTextColor(Ritual ritual) async {
      // final palette = await paletteGenerator(File(ritual.background!));

      // Use the dominant color from the generated palette
      // cardTextColor = palette.dominantColor?.color;
      // debugPrint("CardTextColor: $cardTextColor");

      /*if (cardTextColor != null) {
        debugPrint("Inverting Colors");
        // Invert the color
        cardTextColor = Color.fromARGB(
          cardTextColor!.alpha,
          255 - cardTextColor!.red,
          255 - cardTextColor!.green,
          255 - cardTextColor!.blue,
        );
      }

      // Ensure the UI is updated with the new color
      setState(() {});*/
    }

    if (ritual.background == Constants.noBackground) {
      cardTextColor = Colors.black;
    } else {
      // Load the image and generate the palette
      debugPrint("Running palette gen");
      generateTextColor(ritual);
      debugPrint("Palette Gen Ran");
    }

    // Calculate the percentage complete of ritual
    if (type == typeRitual) {
      final rituals = Boxes.getBox().values.toList().cast<Ritual>();

      int habits = 0;
      int complete = 0;

      for (Ritual r in rituals) {
        if (r.url.contains(ritual.url) && (r.type?.contains("habit") ?? false)) {
          // Higher priority, higher complete
          habits += (5 - r.priority);

          if (r.complete == 1) {
            complete += (5 - r.priority);
          }
        }
      }

      ritual.complete = (habits == 0) ? 1 : complete / habits;
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
                        "assets/illustrations/$type.jpg",
                        fit: BoxFit.cover,
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
                      style: TextStyle(
                          fontSize: 23,
                          // color: Colors.white,
                          // color: ritual.background == Constants.noBackground ? Colors.black: paletteGenerator(File(ritual.background!)).then((value) => value.dominantColor),
                          color: cardTextColor,
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
                        ritual.time != null ? TimeOfDay(hour: int.parse(ritual.time!.split(':')[0]), minute: int.parse(ritual.time!.split(':')[1])).format(context) : "",
                        maxLines: 2,
                        style: const TextStyle(
                            fontSize: 23,
                            color: Colors.red,
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
