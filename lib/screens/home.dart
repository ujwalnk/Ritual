import 'package:Ritual/services/boxes.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

// Hive database packages
import 'package:Ritual/model/ritual.dart';

// Services
import 'package:Ritual/services/registry.dart';
import 'package:Ritual/services/expandableFAB.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ExpandableFab fab = ExpandableFab();

  @override
  void dispose() {
    // Close all open Boxes
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Home",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "NotoSans-Light",
          ),
        ),
        backgroundColor: Colors.blue[800],
        shadowColor: Colors.blue[400],
        elevation: 2,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(17.0, 16.0, 0, 16.0),
              child: Text(
                "Highlight",
                style: TextStyle(fontSize: 22, fontFamily: "NotoSans-Light"),
              ),
            ),
            ValueListenableBuilder<Box<Ritual>>(
              valueListenable: Boxes.getRituals().listenable(),
              builder: (context, box, _) {
                final contents = box.values.toList().cast<Ritual>();
                var rituals = <Ritual>[];
                for (var ritual in contents) {
                  if (ritual.type == "highlight") {
                    rituals.add(ritual);
                  }
                }
                debugPrint("Rituals: ${rituals.length}");
                return buildContent(rituals, type: "Highlight");
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(17.0, 16.0, 0, 16.0),
              child: Text(
                "Sprint",
                style: TextStyle(fontSize: 22, fontFamily: "NotoSans-Light"),
              ),
            ),
            ValueListenableBuilder<Box<Ritual>>(
              valueListenable: Boxes.getRituals().listenable(),
              builder: (context, box, _) {
                final contents = box.values.toList().cast<Ritual>();
                var rituals = <Ritual>[];
                for (var ritual in contents) {
                  if (ritual.type == "sprint") {
                    rituals.add(ritual);
                  }
                }
                debugPrint("Rituals: ${rituals.length}");
                return buildContent(rituals, type: "Sprint");
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(17.0, 16.0, 0, 16.0),
              child: Text(
                "Ritual",
                style: TextStyle(fontSize: 22, fontFamily: "NotoSans-Light"),
              ),
            ),
            ValueListenableBuilder<Box<Ritual>>(
              valueListenable: Boxes.getRituals().listenable(),
              builder: (context, box, _) {
                final contents = box.values.toList().cast<Ritual>();
                var rituals = <Ritual>[];
                for (var ritual in contents) {
                  if (ritual.type == "ritual") {
                    rituals.add(ritual);
                  }
                }
                debugPrint("Rituals: ${rituals.length}");
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

  Widget buildContent(List<Ritual> rituals, {String type = "ritual"}) {
    if (rituals.isEmpty) {
      // Return a message or an empty state widget when there are no rituals.
      return Center(
        child: Text(
          'Tap the + icon to create your first $type',
          style: TextStyle(fontSize: 18),
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final ritual in rituals) buildCard(context, ritual, isRitual: type == "ritual" ? true : false),
        ],
      );
    }
  }

  Widget buildCard(BuildContext context, Ritual ritual,
      {bool isRitual = true}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(70.0, 0, 0, 0),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (isRitual) {
            Navigator.pushNamed(context, "/rituals", arguments: {
              "background": ritual.background!,
              "ritual": ritual.url,
            });
          }
        },
        child: SizedBox(
          height: 100,
          child: Card(
            color: Colors.transparent,
            elevation: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Stack(
                // Use a Stack to overlay the image and text.
                children: [
                  // Background
                  Image.asset(
                    ritual.background!,
                    fit: BoxFit.cover,
                    width: double
                        .infinity, // Make the image fill the Card horizontally.
                    height: 200,
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
                          color: Colors.white,
                          fontFamily: "NotoSans-Light"),
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
