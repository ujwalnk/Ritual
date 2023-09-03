import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

// Hive database packages
import 'package:Ritual/model/ritual.dart';

// Services
import 'package:Ritual/services/registry.dart';
import 'package:Ritual/services/boxes.dart';

class commit2Ritual extends StatefulWidget {
  const commit2Ritual({super.key});

  @override
  State<commit2Ritual> createState() => _commit2RitualState();
}

class _commit2RitualState extends State<commit2Ritual> {
  TextEditingController _textFieldController = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();

  @override
  void dispose(){
    // Close all boxes
    Hive.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
          "Commit",
          style: TextStyle(fontFamily: "NotoSans-Light"),
        )),
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: <Widget>[
              Text(
                "Commit to",
                style:
                    TextStyle(fontSize: 20, fontFamily: "NotoSans-Light"),
              ),
              SizedBox(height: 30),
              TextField(
                controller: _textFieldController,
                focusNode: _textFieldFocusNode,
                decoration: InputDecoration(
                    border: const OutlineInputBorder(), hintText: "What would you like to call your amazing Ritual"),
              ),
              SizedBox(height: 30),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Visibility(
                    child: FilledButton.tonal(
                      onPressed: () {
                        final ritual = Ritual()
                        ..complete = 0
                        ..url = "/${_textFieldController.text}"
                        ..background = "assets/images/ritualBackground.jpg"
                        ..type = "ritual";

                        final box = Boxes.getRituals();
                        box.add(ritual);

                        // Pop the screen
                        Navigator.pop(context);
                      },
                      child: Text("Commit",
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