import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

// Hive database packages
import 'package:Ritual/model/ritual.dart';

// Services
import 'package:Ritual/services/registry.dart';
import 'package:Ritual/services/boxes.dart';

class commit2Habit extends StatefulWidget {
  const commit2Habit({super.key});

  @override
  State<commit2Habit> createState() => _commit2HabitState();
}

class _commit2HabitState extends State<commit2Habit> {
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

    Map data = ModalRoute.of(context)?.settings.arguments as Map;

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
                    border: const OutlineInputBorder(), 
                    hintText: data['mode'] == "new" ? "What's new in ${data['uri'].toString().replaceFirst("/", "")}" : "Rename to"
                  ),
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
                        ..url = "${data['uri']}/${_textFieldController.text}"
                        ..type = "habit";

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