import 'package:flutter/material.dart';

// Hive database packages
import 'package:ritual/model/ritual.dart';

// Services
import 'package:ritual/services/boxes.dart';

class Commit2Highlight extends StatefulWidget {
  const Commit2Highlight({super.key});

  @override
  State<Commit2Highlight> createState() => _Commit2HighlightState();
}

class _Commit2HighlightState extends State<Commit2Highlight> {
  final TextEditingController _textFieldController = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text(
          "Commit",
          style: TextStyle(fontFamily: "NotoSans-Light"),
        )),
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
                onChanged: (text) {setState(() {});},
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "What's your highlight"),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Visibility(
                    visible: _textFieldController.text.isNotEmpty && !(_textFieldController.text.contains("/")),
                    child: FilledButton.tonal(
                      onPressed: () {
                        DateTime now = DateTime.now();
                        final ritual = Ritual()
                          ..complete = 0
                          ..url = "/${_textFieldController.text}"
                          ..background = "assets/images/highlightBackground.jpg"
                          ..type = "highlight"
                          // Highlight expires the next day
                          ..expiry = DateTime(
                              now.year, now.month, now.day + 1, 0, 0, 0, 0);

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
