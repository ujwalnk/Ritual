import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Hive database packages
import 'package:ritual/model/ritual.dart';

// Services
import 'package:ritual/services/boxes.dart';
import 'package:ritual/services/constants.dart';
import 'package:ritual/services/widgets/image_picker.dart';
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
  Map cardIllustrations = {};

  TimeOfDay selectedTime = TimeOfDay.now();
  bool _init = false;

  String cardBackgroundPath = Constants.noBackground;

  @override
  Widget build(BuildContext context) {
    // Get data from parent screen
    Map data = ModalRoute.of(context)?.settings.arguments as Map;

    // Focus the text Field
    _textFieldFocusNode.requestFocus();

    if (!_init) {
      selectedTime = (data['time'] == null)
          ? TimeOfDay.now()
          : TimeOfDay(
              hour: data['time']['hour'], minute: data['time']['minute']);
      _init = !_init;
    }

        // Precache card illustrations
    for (var image in Constants.illustrations) {
      cardIllustrations.addAll({
        image: Image.asset(
          image,
          fit: BoxFit.cover,
          // width: double.infinity,
          height: 200,
        )
      });
      precacheImage(cardIllustrations[image].image, context);
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
                    onPressed: () async {
                      debugPrint("@Ritual: Deleting Ritual");

                      // Delete the image file
                      if (data['ritual'].background != Constants.noBackground) {
                        await File(data['ritual'].background).delete();
                      }

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
                          fontSize: 20,
                          fontFamily: "NotoSans-Light",
                        )),
                    // onPressed: () => _getImage(data),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomImagePicker(
                            onImageSelected: (String selectedImage) {
                              cardBackgroundPath = selectedImage;
                              debugPrint("@ritual: Image selected: $selectedImage");
                            },
                            cardIllustrations: cardIllustrations,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Visibility(
                    visible: (_textFieldController.text.isNotEmpty ||
                            (data['mode'] == "edit")) &&
                        !_textFieldController.text.contains("/"),
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
                            ..type = Constants.typeRitual
                            ..time = {
                              "hour": selectedTime.hour,
                              "minute": selectedTime.minute
                            };

                          box.add(ritual);
                        } else {
                          // Editing a pre-existing Ritual

                          // Get all rituals
                          final contents = box.values.toList().cast<Ritual>();

                          for (Ritual ritual in contents) {
                            // Edit time and name of ritual
                            if (ritual.url.contains(data['uri']) &&
                                (ritual.type!.contains(Constants.typeHabits) ||
                                    ritual.type == Constants.typeRitual)) {
                              debugPrint(
                                  "@ritual: Renaming ritual ${ritual.url} to /${_textFieldController.text}");
                              if (_textFieldController.text.isNotEmpty) {
                                ritual.url = ritual.url.replaceAll(data['uri'],
                                    "/${_textFieldController.text}");
                              }
                              if (cardBackgroundPath.isNotEmpty) {
                                ritual.background = cardBackgroundPath;
                              }
                              ritual.time = {
                                "hour": selectedTime.hour,
                                "minute": selectedTime.minute
                              };

                              ritual.save();
                              debugPrint("@ritual: Renamed to: ${ritual.url}");
                            }
                          }
                        }

                        // Set future Notifications
                        // NotificationService().scheduleNotification(
                        //     title: 'Scheduled Notification',
                        //     body: '$scheduleTime',
                        //     scheduledNotificationDateTime: scheduleTime);

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

  /// Update the selected time
  void handleTimeSelected(TimeOfDay time) {
    setState(() {
      debugPrint("Setting time to $time");
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
      if ((ritual.type!.contains(Constants.typeHabits) ||
              ritual.type == Constants.typeRitual) &&
          ritual.url.contains(currentRitualURL)) {
        box.delete(ritual.key);
      }
    }

    // Return to home screen
    Navigator.of(context).popUntil(ModalRoute.withName("Home"));
  }
}
