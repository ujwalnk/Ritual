import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

// Hive database packages
import 'package:ritual/model/ritual.dart';

// Services
import 'package:ritual/services/boxes.dart';
import 'package:ritual/services/widgets/time_picker.dart';
import 'package:ritual/services/shared_prefs.dart';

class Commit2Ritual extends StatefulWidget {
  const Commit2Ritual({super.key});

  @override
  State<Commit2Ritual> createState() => _Commit2RitualState();
}

class _Commit2RitualState extends State<Commit2Ritual> {
  final TextEditingController _textFieldController = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();

  TimeOfDay selectedTime = TimeOfDay.now();

  String cardBackgroundPath = "white";

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
                        : "Rename your Ritual ${data['uri'].replaceFirst('/', '')} to"),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "A Background",
                    style:
                        TextStyle(fontSize: 20, fontFamily: "NotoSans-Light"),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text("Pick an Image",
                        style: TextStyle(
                            fontSize: 20, fontFamily: "NotoSans-Light")),
                    onPressed: () => _getImage(data),
                  ),
                ],
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Visibility(
                    visible: _textFieldController.text.isNotEmpty || (data['mode'] == "edit"),
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

  void _getImage(Map data) async {
    // Pick an image from the user gallery
    ImagePicker imagePicker = ImagePicker();
    final imageFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      // Get the application directory
      final String appDirPath = (await getApplicationDocumentsDirectory()).path;

      setState(() {
        // int fileNameIndex = imageFile.path.lastIndexOf("/");
        int fileExtensionIndex = imageFile.path.lastIndexOf(".");

        // cardBackgroundPath: <app_folder>/images/<current_file_sequence>.<image_extension>
        if (data['mode'] == "new") {
          cardBackgroundPath =
              "$appDirPath/images/${SharedPreferencesManager().getFileSequence()}${imageFile.path.substring(fileExtensionIndex)}";

          // Increment the file numbering sequence
          SharedPreferencesManager().setFileSequence(
              SharedPreferencesManager().getFileSequence() + 1);
        } else if ((data['mode'] == "edit") &&
            (data["background"] != "white")) {
          cardBackgroundPath = data['background'];

          // On image replace, needs a cache refresh
          imageCache.clearLiveImages();
        } else {
          cardBackgroundPath =
              "$appDirPath/images/${SharedPreferencesManager().getFileSequence()}${imageFile.path.substring(fileExtensionIndex)}";

          // Increment the file numbering sequence
          SharedPreferencesManager().setFileSequence(
              SharedPreferencesManager().getFileSequence() + 1);
        }
      });

      File imageFileTemp = File(imageFile.path);
      try {
        // Create directory if not exist
        Directory("$appDirPath/images").createSync(recursive: true);

        // Copy the source file to internal memory
        await imageFileTemp.copy(cardBackgroundPath);

        // Check if the file was successfully copied
        if (File("$appDirPath$cardBackgroundPath").existsSync()) {
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
    } else {
      // Set it to default value to show white background
      cardBackgroundPath = "white";
    }
  }


  /// Update the selected time
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
    Navigator.of(context).popUntil(ModalRoute.withName("Home"));
  }
}
