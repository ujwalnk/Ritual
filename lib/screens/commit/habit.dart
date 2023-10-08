import 'package:flutter/material.dart';

// Hive database packages
import 'package:ritual/model/ritual.dart';

// Services
import 'package:ritual/services/boxes.dart';
import 'package:ritual/services/ritual_icons.dart';
import 'package:ritual/services/constants.dart';

import 'package:duration_picker/duration_picker.dart';

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

  // Define a list of habit types with associated icons.
  final List<Map<String, dynamic>> habitTypes = [
    {
      'text': 'Habit',
      'icon': const Icon(CustomIcons.puzzle),
      'value': Constants.typeRHabit
    },
    {
      'text': 'deHabit',
      'icon': const Icon(CustomIcons.puzzleOutline),
      'value': Constants.typeDHabit
    },
    {
      'text': '1% habit',
      'icon': const Icon(CustomIcons.circle1),
      'value': Constants.type1Habit
    },
    {
      'text': 'Timed Habits',
      'icon': const Icon(CustomIcons.hourglass),
      'value': Constants.typeTHabit
    },
  ];

  // Set defaults - Priority 4 and Regular Habit
  String selectedPriority = "Priority 4";
  String selectedType = Constants.typeRHabit;

  bool initWidget = false;

  Duration d = const Duration(minutes: -1);

  @override
  Widget build(BuildContext context) {
    Map data = ModalRoute.of(context)?.settings.arguments as Map;

    if (!initWidget) {
      initWidget = true;
      // OnEdit set Habit properties:
      selectedPriority = data['mode'] == "edit"
          ? "Priority ${data['ritual'].priority}"
          : "Priority 4";
      selectedType = data['mode'] == "edit"
          ? data['ritual'].type.toString().substring(
              data['ritual'].type.toString().indexOf("/") + 1,
              data['ritual'].type.toString().length)
          : Constants.typeRHabit;
    }

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
                  const Text(
                    "Choose Priority",
                    style:
                        TextStyle(fontSize: 20, fontFamily: "NotoSans-Light"),
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
                                  fontFamily: "NotoSans-Light"),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Choose Type",
                    style:
                        TextStyle(fontSize: 20, fontFamily: "NotoSans-Light"),
                  ),
                  DropdownButton<String>(
                    value: selectedType,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedType = newValue!;
                      });
                    },
                    // Create dropdown items based on the priorities list.
                    items: habitTypes.map((habitType) {
                      return DropdownMenuItem<String>(
                        value: habitType['value'],
                        child: Row(
                          children: [
                            // Add a icon before the text.
                            Container(
                              width: 24,
                              height: 24,
                              child: habitType['icon'],
                              margin: const EdgeInsets.only(right: 10.0),
                            ),
                            Text(
                              habitType['text'],
                              style:
                                  const TextStyle(fontFamily: "NotoSans-Light"),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Choose Duration",
                    style:
                        TextStyle(fontSize: 20, fontFamily: "NotoSans-Light"),
                  ),
                  TextButton.icon(
                      onPressed: () async {
                        var resultingDuration = await showDurationPicker(
                          context: context,
                          initialTime: Duration(minutes: data['mode'] == "edit" ? data['ritual'].duration.inMinutes : 5),
                          snapToMins: 5,
                        );

                        d = resultingDuration ?? (d.isNegative ? Duration.zero : d);
                        setState(() {});
                      },
                      icon: const Icon(Icons.timelapse),
                      label: Text(d.isNegative ? "Pick Duration" : "${d.inMinutes} Min")
                      )
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
                        debugPrint(
                            "Priority: ${int.parse(selectedPriority.substring(selectedPriority.length - 1))}");

                        if (data['mode'] == "new") {
                          final ritual = Ritual()
                            ..complete = 0
                            ..url =
                                "${data['uri']}/${_textFieldController.text}"
                            ..type = "habit/$selectedType"
                            ..position = data['position']
                            ..priority = int.parse(selectedPriority
                                .substring(selectedPriority.length - 1))
                            ..createdOn = DateTime.now()
                            ..duration = d;

                          final box = Boxes.getBox();
                          box.add(ritual);
                        } else {
                          Ritual r = Boxes.getBox().get(data['ritual'].key)!;

                          // Change the name
                          if (_textFieldController.text.isNotEmpty) {
                            r.url =
                                r.url.substring(0, r.url.lastIndexOf("/") + 1) +
                                    _textFieldController.text;
                          }

                          // Set the priority
                          r.priority = int.parse(selectedPriority
                              .substring(selectedPriority.length - 1));

                          // Set the type
                          r.type = "habit/$selectedType";
                          r.duration = d;
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
