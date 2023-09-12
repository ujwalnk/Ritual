import 'package:flutter/material.dart';

// Hive database packages
import 'package:Ritual/model/ritual.dart';

// Services
import 'package:Ritual/services/boxes.dart';
import 'package:Ritual/services/widgets/date_picker.dart';

class Commit2Sprint extends StatefulWidget {
  const Commit2Sprint({super.key});

  @override
  State<Commit2Sprint> createState() => _Commit2SprintState();
}

class _Commit2SprintState extends State<Commit2Sprint> {
  final TextEditingController _textFieldController = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();

  DateTime? selectedDate;

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
                style:
                    TextStyle(fontSize: 20, fontFamily: "NotoSans-Light"),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _textFieldController,
                focusNode: _textFieldFocusNode,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: "What's your latest Sprint"),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text(
                    "Sprint Until",                
                    style:
                        TextStyle(fontSize: 20, fontFamily: "NotoSans-Light"),
                  ),
                  CustomDatePicker(restorationId: "datepicker", onDateSelected: handleDateSelected)
                ],
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Visibility(
                    visible: (selectedDate != null) && (_textFieldController.text.isNotEmpty),
                    child: FilledButton.tonal(
                      onPressed: () {
                        final ritual = Ritual()
                        ..complete = 0
                        ..url = "/${_textFieldController.text}"
                        ..background = "assets/images/highlightBackground.jpg"
                        ..type = "sprint"
                        ..expiry = selectedDate;

                        final box = Boxes.getRituals();
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

  // Callback function to receive the selected date
  void handleDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }
}