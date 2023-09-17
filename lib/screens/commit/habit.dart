import 'package:flutter/material.dart';

// Hive database packages
import 'package:ritual/model/ritual.dart';

// Services
import 'package:ritual/services/boxes.dart';

class Commit2Habit extends StatefulWidget {
  const Commit2Habit({super.key});

  @override
  State<Commit2Habit> createState() => _Commit2HabitState();
}

class _Commit2HabitState extends State<Commit2Habit> {
  final TextEditingController _textFieldController = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();

  @override
  void dispose() {
    // Close all boxes
    // Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map data = ModalRoute.of(context)?.settings.arguments as Map;

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Commit",
            style: TextStyle(fontFamily: "NotoSans-Light"),
          ),
          actions: data['mode'] == "edit"
              ? <Widget>[
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      debugPrint("@Ritual: Deleting habit");
                      // TODO: Write delete habit functionality
                    },
                  )
                ]
              : [],
        ),
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: <Widget>[
              const Text(
                "Commit to",
                style: TextStyle(fontSize: 20, fontFamily: "NotoSans-Light"),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _textFieldController,
                focusNode: _textFieldFocusNode,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: data['mode'] == "new"
                        ? "What's new in ${data['uri'].toString().replaceFirst("/", "")}"
                        : "Rename ${data['uri'].toString().replaceFirst('/', '')}"),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Visibility(
                    child: FilledButton.tonal(
                      onPressed: () {
                        final ritual = Ritual()
                          ..complete = 0
                          ..url = "${data['uri']}/${_textFieldController.text}"
                          ..type = "habit";

                        final box = Boxes.getBox();
                        box.add(ritual);

                        // Pop the screen
                        Navigator.pop(context);
                      },
                      child: const Text("Commit",
                          style: TextStyle(
                              fontFamily: "NotoSans-Light", fontSize: 20)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
