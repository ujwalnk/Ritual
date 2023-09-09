import 'package:flutter/material.dart';

import 'package:Ritual/services/boxes.dart';
import 'package:Ritual/model/ritual.dart';
import 'package:Ritual/services/registry.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Rituals extends StatefulWidget {
  const Rituals({super.key});

  @override
  State<Rituals> createState() => _RitualsState();
}

class _RitualsState extends State<Rituals> {
  @override
  Widget build(BuildContext context) {
    // Data from caller page
    // TODO: Send data from the previous page
    Map data = ModalRoute.of(context)?.settings.arguments as Map;

    return Scaffold(
      // Status bar transparent with body
      extendBodyBehindAppBar: true,

      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("${data['background']}"),
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
                      Navigator.pushNamed(context, "/commit/habit",
                          arguments: {"uri": data["ritual"], "mode": "new"});
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          ValueListenableBuilder<Box<Ritual>>(
            valueListenable: Boxes.getRituals().listenable(),
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

  Widget buildContent(List<Ritual> content) {
    if (content.isEmpty) {
      // Return a message
      return Center(
        child: Text(
          'Tap the + icon to add a new habit',
          style: TextStyle(fontSize: 18),
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final ritual in content) buildCard(context, ritual),
        ],
      );
    }
  }

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
        } else{
          // Don't uncheck habits
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Trying to uncheck?'),
                  content: Text('Commitments fullfilled; Why unmark accomplishments?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        // Close the dialog
                        Navigator.of(context).pop();
                      },
                      child: Text('Makes Sense'),
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
          color: Colors.white,
          elevation: 1,
          child: Center(
            child: Text(
              ritual.url.split("/").last,
              maxLines: 2,
              style: TextStyle(
                fontSize: 23,
                color: Colors.black,
                fontFamily: "NotoSans-Light",
                // TODO: Strikethrough based on completion status
                decoration: ritual.complete == 1
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
