import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

// Hive database packages
import 'package:ritual/model/ritual.dart';

// Services
import 'package:ritual/services/boxes.dart';
import 'package:ritual/services/widgets/time_picker.dart';
import 'package:ritual/services/hash.dart';

class Commit2Ritual extends StatefulWidget {
  const Commit2Ritual({super.key});

  @override
  State<Commit2Ritual> createState() => _Commit2RitualState();
}

class _Commit2RitualState extends State<Commit2Ritual> {
  final TextEditingController _textFieldController = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();

  TimeOfDay selectedTime = TimeOfDay.now();

  String cardBackgroundPath = "";

  @override
  Widget build(BuildContext context) {
    // Get data from parent screen
    Map data = ModalRoute.of(context)?.settings.arguments as Map;

    selectedTime = data['time'] == null
        ? TimeOfDay.now()
        : TimeOfDay(
            hour: int.parse(data['time'].split(":")[0]) % 12 +
                (data['time'].endsWith("PM") ? 12 : 0),
            minute: int.parse(data['time'].split(":")[1].split(" ")[0]));
    debugPrint("@ritual: selectedTime: $selectedTime");

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
                      debugPrint("@Ritual: Deleting Ritual");
                      deleteRitual(data['uri']);
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
                        ? "What would you like to call your amazing Ritual"
                        : "Rename ${data['uri'].replaceFirst('/', '')}"),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text(
                    "Start Ritual at",
                    style:
                        TextStyle(fontSize: 20, fontFamily: "NotoSans-Light"),
                  ),
                  TimePicker(
                      key: const Key("key_timepicker"),
                      onTimeSelected: handleTimeSelected,
                      selectedTime: selectedTime),
                ],
              ),
              const SizedBox(height: 30),
              TextButton.icon(
                icon: const Icon(Icons.image),
                label: const Text("Pick an Image"),
                onPressed: _getImage,
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Visibility(
                    visible: _textFieldController.text.isNotEmpty &&
                        cardBackgroundPath.isNotEmpty,
                    child: FilledButton.tonal(
                      onPressed: () {
                        // Get boxes
                        final box = Boxes.getBox();

                        if (data['mode'] == "new") {
                          // Adding new Ritual
                          final ritual = Ritual()
                            ..complete = 0
                            ..url = "/${_textFieldController.text}"
                            ..background = cardBackgroundPath
                            ..type = "ritual"
                            ..time =
                                "${selectedTime.hour > 12 ? selectedTime.hour - 12 : selectedTime.hour}:${selectedTime.minute} ${selectedTime.hour >= 12 ? "PM" : "AM"}";

                          box.add(ritual);
                        } else {
                          // Editing a pre-existing Ritual

                          // Get all rituals
                          final contents = box.values.toList().cast<Ritual>();

                          for (Ritual ritual in contents) {
                            // Edit time and name of ritual
                            if (ritual.url.contains(data['uri']) &&
                                (ritual.type == "habit" ||
                                    ritual.type == "ritual")) {
                              debugPrint(
                                  "@ritual: Renaming ritual ${ritual.url} to /${_textFieldController.text}");
                              if (_textFieldController.text.isNotEmpty) {
                                ritual.url = ritual.url.replaceAll(data['uri'],
                                    "/${_textFieldController.text}");
                              }
                              if (cardBackgroundPath.isNotEmpty) {
                                ritual.background = cardBackgroundPath;
                              }
                              ritual.time =
                                  "${selectedTime.hour > 12 ? selectedTime.hour - 12 : selectedTime.hour}:${selectedTime.minute} ${selectedTime.hour >= 12 ? "PM" : "AM"}";
                              ritual.save();
                              debugPrint("@ritual: Renamed to: ${ritual.url}");
                            }
                          }
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

  void _getImage() async {
    // Pick an image from the user gallery
    ImagePicker imagePicker = ImagePicker();
    final imageFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      // Get the application directory
      final String appDirPath = (await getApplicationDocumentsDirectory()).path;

      setState(() {
      int fileNameIndex = imageFile.path.lastIndexOf("/");
      cardBackgroundPath = 
          "$appDirPath${imageFile.path.substring(fileNameIndex)}";
      });

      File imageFileTemp = File(imageFile.path);
      try {
        // Copy the source file to the destination
        await imageFileTemp.copy(cardBackgroundPath);

        // Check if the file was successfully copied
        if (File(cardBackgroundPath).existsSync()) {
          debugPrint('File copied to: $cardBackgroundPath');
        } else {
          debugPrint('Failed to copy the file.');
        }
      } catch (e) {
        // Handle any errors that may occur during the copy operation
        debugPrint('Error copying the file: $e');
      }

      // imageFile.saveTo(cardBackgroundPath);
      debugPrint("@ritual: CardbackgroundPath: $cardBackgroundPath");
    }
  }

  void handleTimeSelected(TimeOfDay time) {
    setState(() {
      selectedTime = time;
    });
  }

  /// Delete the current ritual & habits
  void deleteRitual(String currentRitualURL) {
    final box = Boxes.getBox();

    // Get all rituals
    final contents = box.values.toList().cast<Ritual>();

    for (var ritual in contents) {
      // Delete all rituals having the same URL
      if ((ritual.type == "habit" || ritual.type == "ritual") &&
          ritual.url.contains(currentRitualURL)) {
        box.delete(ritual.key);
      }
    }

    // Return to home screen
    int count = 0;
    Navigator.of(context).popUntil((_) => count++ >= 2);
  }
}
