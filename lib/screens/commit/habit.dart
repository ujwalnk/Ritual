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
  // Controllers for Habit Names
  final TextEditingController _textFieldController = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();

  // Controllers for InitialValue TextBox
  final TextEditingController _textFieldControllerIV = TextEditingController();
  final FocusNode _textFieldFocusNodeIV = FocusNode();

  // Define a list of priorities with associated colors.
  final List<Map<String, dynamic>> priorities = [
    {
      'text': 'Priority 1',
      'color': Colors.red,
      'icon': const Icon(CustomIcons.circle1, size: 16, color: Colors.red)
    },
    {
      'text': 'Priority 2',
      'color': Colors.orange,
      'icon': const Icon(CustomIcons.circle2, size: 16, color: Colors.orange)
    },
    {
      'text': 'Priority 3',
      'color': Colors.blue,
      'icon': const Icon(CustomIcons.circle3, size: 16, color: Colors.blue)
    },
    {
      'text': 'Priority 4',
      'color': Colors.black,
      'icon': const Icon(CustomIcons.circle4, size: 16, color: Colors.black)
    },
  ];

  // Define a list of habit types with associated icons.
  final List<Map<String, dynamic>> habitTypes = [
    {
      'text': 'Regular',
      'icon': const Icon(CustomIcons.rHabit, size: 16),
      'value': Constants.typeRHabit
    },
    {
      'text': 'deHabit',
      'icon': const Icon(CustomIcons.dHabit, size: 16),
      'value': Constants.typeDHabit
    },
    {
      'text': 'Stack',
      'icon': const Icon(CustomIcons.sHabit, size: 16),
      'value': Constants.typeSHabit
    },
    {
      'text': 'Timed',
      'icon': const Icon(CustomIcons.tHabit, size: 16),
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
      d = data['mode'] == "edit"
          ? Duration(minutes: data['ritual'].duration)
          : const Duration(minutes: -1);
      // Focus on the text Field
      _textFieldFocusNode.requestFocus();
    }

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
          child: SingleChildScrollView(
            child: SizedBox(
              height: double.maxFinite,
              child: Column(
                children: <Widget>[
                  const Text(
                    "Commit to",
                    style:
                        TextStyle(fontSize: 20, fontFamily: "NotoSans-Light"),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    key: const Key("textField1"),
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
                        style: TextStyle(
                            fontSize: 20, fontFamily: "NotoSans-Light"),
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
                                // Add a icon before the text.
                                Container(
                                  width: 24,
                                  height: 24,
                                  child: priority['icon'],
                                  margin: const EdgeInsets.only(right: 8.0),
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
                        "Choose Habit Type",
                        style: TextStyle(
                            fontSize: 20, fontFamily: "NotoSans-Light"),
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
                                  margin: const EdgeInsets.only(right: 16.0),
                                ),
                                Text(
                                  habitType['text'],
                                  style: const TextStyle(
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
                        "Choose Duration",
                        style: TextStyle(
                            fontSize: 20, fontFamily: "NotoSans-Light"),
                      ),
                      TextButton.icon(
                          onPressed: () async {
                            var resultingDuration = await showDurationPicker(
                              context: context,
                              initialTime: Duration(
                                  minutes: data['mode'] == "edit"
                                      ? data['ritual'].duration
                                      : 5),
                              snapToMins: 5,
                            );

                            d = resultingDuration ??
                                (d.isNegative ? Duration.zero : d);
                            setState(() {});
                          },
                          icon: const Icon(Icons.timelapse),
                          label: Text(d.isNegative
                              ? "Pick Duration"
                              : "${d.inMinutes} Min")),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Visibility(
                    visible: selectedType == Constants.typeSHabit,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text(
                          "Initial Value",
                          style: TextStyle(
                              fontSize: 20, fontFamily: "NotoSans-Light"),
                        ),
                        SizedBox(
                          width: 150,
                          child: TextField(
                            key: const Key("textField2"),
                            controller: _textFieldControllerIV,
                            focusNode: _textFieldFocusNodeIV,
                            onChanged: (text) {
                              setState(() {});
                            },
                            decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText: data['mode'] == "new"
                                    ? ""
                                    : "${data['ritual'].duration}"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Visibility(
                        visible: !_textFieldController.text.contains("/") &&
                            ((data['mode'] == "edit") ||
                                (_textFieldController.text.isNotEmpty &&
                                   ( d.inMinutes != -1))),
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
                                ..duration = d.inMinutes;

                              final box = Boxes.getBox();
                              box.add(ritual);
                            } else {
                              Ritual r =
                                  Boxes.getBox().get(data['ritual'].key)!;

                              // Change the name
                              if (_textFieldController.text.isNotEmpty) {
                                r.url = r.url.substring(
                                        0, r.url.lastIndexOf("/") + 1) +
                                    _textFieldController.text;
                              }

                              // Set the priority
                              r.priority = int.parse(selectedPriority
                                  .substring(selectedPriority.length - 1));

                              // Set the type
                              r.type = "habit/$selectedType";
                              r.duration = d.inMinutes;
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
            ),
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
