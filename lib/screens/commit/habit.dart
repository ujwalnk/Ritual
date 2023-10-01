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

  // Define a list of priorities with associated colors.
  final List<Map<String, dynamic>> priorities = [
    {'text': 'Priority 1', 'color': Colors.red},
    {'text': 'Priority 2', 'color': Colors.orange},
    {'text': 'Priority 3', 'color': Colors.blue},
    {'text': 'Priority 4', 'color': Colors.black},
  ];

  String selectedPriority = "Priority 4";

  @override
  Widget build(BuildContext context) {
    Map data = ModalRoute.of(context)?.settings.arguments as Map;

    _textFieldFocusNode.requestFocus();

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
                      deleteHabit(data['ritual']);
                      Navigator.pop(context);
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
                onChanged: (text) {
                  setState(() {});
                },
                decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: data['mode'] == "new"
                        ? "What's new in ${data['uri'].toString().replaceFirst("/", "")}"
                        : "Rename ${data['uri'].toString().replaceFirst("/", '').substring(data['uri'].toString().replaceFirst("/", '').indexOf('/')).replaceFirst('/', '')}"),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _textFieldController.text.isEmpty
                        ? "Choose Priority"
                        : "Priority of ${_textFieldController.text}",
                    style:
                        const TextStyle(fontSize: 20, fontFamily: "NotoSans-Light"),
                  ),
                  DropdownButton<String>(
                    value: selectedPriority,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPriority = newValue!;
                      });
                    },
                    // Create dropdown items based on the priorities list.
                    items: priorities.map((priority) {
                      return DropdownMenuItem<String>(
                        value: priority['text'],
                        child: Row(
                          children: [
                            // Add a colored bullet before the text.
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: priority['color'],
                              ),
                              margin: const EdgeInsets.only(right: 10.0),
                            ),
                            Text(
                              priority['text'],
                              style: TextStyle(
                                color: priority['color'],
                                fontFamily: "NotoSans-Light"
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Visibility(
                    visible: !_textFieldController.text.contains("/") &&
                        ((data['mode'] == "edit") ||
                            (_textFieldController.text.isNotEmpty)),
                    child: FilledButton.tonal(
                      onPressed: () {
                        debugPrint("Priority: ${int.parse(selectedPriority.substring(selectedPriority.length - 1))}");

                        if (data['mode'] == "new") {
                          final ritual = Ritual()
                            ..complete = 0
                            ..url =
                                "${data['uri']}/${_textFieldController.text}"
                            ..type = "habit"
                            ..position = data['position']
                            ..priority = int.parse(selectedPriority.substring(selectedPriority.length - 1));


                          final box = Boxes.getBox();
                          box.add(ritual);
                        } else {
                          debugPrint("@habit Edit habit");
                          Ritual r = Boxes.getBox().get(data['ritual'].key)!;
                          // r.url = "${data['uri']}/${_textFieldController.text}";
                          if (_textFieldController.text.isNotEmpty) {
                            r.url = r.url.replaceAll(data['uri'],
                                  "/${_textFieldController.text}");

                            debugPrint("@habit: Ritual Url: ${r.url}");
                          }
                          r.priority = int.parse(selectedPriority.substring(selectedPriority.length - 1));
                          r.save();
                        }
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

  /// Delete the current ritual & habits
  void deleteHabit(Ritual r) {
    Boxes.getBox().delete(r.key);
    Boxes.getBox().flush();
    setState(() => {});
  }
}
