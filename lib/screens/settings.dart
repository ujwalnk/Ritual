import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:url_launcher/url_launcher.dart';

// Services
import 'package:ritual/services/constants.dart';
import 'package:ritual/services/data_shuttle.dart';
import 'package:ritual/services/shared_prefs.dart';
import 'package:ritual/services/boxes.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  Color accentColor = Color(SharedPreferencesManager().getAccentColor());

  Color getFontColorForBackground(Color background) {
    return (background.computeLuminance() > 0.179)? Colors.black : Colors.white;
  }

  // Spacing between elements of a field
  static const double elementSpacing = 0;

  // Spacing between different fields
  static const double fieldSpacing = 15;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Settings",
            style: TextStyle(
              fontFamily: "NotoSans-Light",
              color: getFontColorForBackground(accentColor),  
            ),
          ),
          backgroundColor: accentColor,
          elevation: 1,
        ),
        body: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: <Widget>[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Features",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "NotoSans-Light")),
              ),
              const SizedBox(height: elementSpacing),
              // Check box for Highlight
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Text("Two Day Rule",
                        style: TextStyle(fontFamily: "NotoSans-Light")),
                    Checkbox(
                      activeColor: accentColor,
                      value: SharedPreferencesManager().getTwoDayRule(),
                      onChanged: (value) async {
                        await SharedPreferencesManager().setTwoDayRule(value!);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: elementSpacing),
              // Check box for Ritual Saturization
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Text("Saturate Ritual Cards",
                        style: TextStyle(fontFamily: "NotoSans-Light")),
                    Checkbox(
                      activeColor: accentColor,
                      value: SharedPreferencesManager().getSaturateCard(),
                      onChanged: (value) async {
                        await SharedPreferencesManager()
                            .setSaturateCard(value!);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: fieldSpacing),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Display",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "NotoSans-Light")),
              ),
              const SizedBox(height: elementSpacing),
              // Check box for Highlight
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Text("Show Highlights",
                        style: TextStyle(fontFamily: "NotoSans-Light")),
                    Checkbox(
                      activeColor: accentColor,
                      value: SharedPreferencesManager().getShowHighlight(),
                      onChanged: (value) async {
                        await SharedPreferencesManager()
                            .setShowHighlight(value!);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: elementSpacing),

              // Check box for Sprint
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Text("Show Sprints",
                        style: TextStyle(fontFamily: "NotoSans-Light")),
                    Checkbox(
                      value: SharedPreferencesManager().getShowSprints(),
                      activeColor: accentColor,
                      onChanged: (value) async {
                        await SharedPreferencesManager().setShowSprints(value!);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: elementSpacing),
              // Check box for Highlight
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Text("Colorize Habit Text",
                        style: TextStyle(fontFamily: "NotoSans-Light")),
                    Checkbox(
                      activeColor: accentColor,
                      value: SharedPreferencesManager().getColorizeHabitText(),
                      onChanged: (value) async {
                        await SharedPreferencesManager()
                            .setColorizeHabitText(value!);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: elementSpacing),
              // App theme color
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const Text("Accent Color",
                        style: TextStyle(fontFamily: "NotoSans-Light")),
                    IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                titlePadding: const EdgeInsets.all(0),
                                contentPadding: const EdgeInsets.all(0),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      MediaQuery.of(context).orientation ==
                                              Orientation.portrait
                                          ? const BorderRadius.vertical(
                                              top: Radius.circular(500),
                                              bottom: Radius.circular(100),
                                            )
                                          : const BorderRadius.horizontal(
                                              right: Radius.circular(500)),
                                ),
                                content: SingleChildScrollView(
                                  child: HueRingPicker(
                                    pickerColor: Color(SharedPreferencesManager().getAccentColor()),
                                    onColorChanged: (Color c){
                                      SharedPreferencesManager().setAccentColor(c.value);
                                      accentColor = c;

                                      // Update the colors
                                      setState(() {});

                                    },
                                    enableAlpha: true,
                                    displayThumbColor: true,
                                  ),
                                ),
                              );
                            },
                          );
                          _restartAlert();
                        },
                        icon: Icon(
                          Icons.palette,
                          color: accentColor,
                        ))
                  ],
                ),
              ),
              const SizedBox(height: fieldSpacing),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Data",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "NotoSans-Light")),
              ),
              const SizedBox(
                height: 20,
              ),
              // SizedBox(
                // width: double.infinity,
                /*child:*/ TextButton(
                  onPressed: () async {
                    debugPrint("Exporting");
                    try {
                      final result =
                          await FilePicker.platform.getDirectoryPath();
                      if (result != null) {
                        // Use the selected path (result) to save your file
                        debugPrint("Selected path: $result");
                        backupHiveBox(result);
                        _snackBar("Backup successful",
                            backgroundColor: Colors.lightGreen);
                      } else {
                        // Show a failure snackbar
                        _snackBar("Backup failed", backgroundColor: Colors.red);
                      }
                    } catch (e) {
                      debugPrint("Error picking a directory: $e");
                      // Show a failure snackbar
                      _snackBar("Backup failed", backgroundColor: Colors.red);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Export",
                          style: TextStyle(fontFamily: "NotoSans-Light")),
                      Icon(Icons.upload_file_rounded,
                          color: accentColor),
                    ],
                  ),
                ),
              // ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () async {
                    debugPrint("Importing");
                    try {
                      final result = await FilePicker.platform.pickFiles();

                      if (result != null && result.files.isNotEmpty) {
                        final file = result.files.first;
                        restoreHiveBox(file.path!);

                        // Show a confirmation dialog to )restart the app
                        _restartAlert();
                      } else {
                        // No file selected
                        _snackBar("No file selected",
                            backgroundColor: Colors.red);
                      }
                    } catch (e) {
                      debugPrint("Error picking a file: $e");

                      // Show a failure snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Restoration failed"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Import",
                          style: TextStyle(fontFamily: "NotoSans-Light")),
                      Icon(Icons.download_rounded,
                          color: accentColor),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () async {
                    debugPrint("Deleting Hive Database");
                    // Show a confirmation dialog to restart the app
                    _deleteForever();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Delete",
                          style: TextStyle(fontFamily: "NotoSans-Light")),
                      Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: fieldSpacing),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Brought to you with love by Madilu",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "NotoSans-Light")),
              ),
              const SizedBox(height: 15),
              // Check box for Highlight
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      behavior: HitTestBehavior.deferToChild,
                      child: const Text("Find any bugs? Report",
                          style: TextStyle(fontFamily: "NotoSans-Light")),
                      onTap: () async {
                        await launchUrl(Uri.parse(
                            "https://github.com/ujwalnk/Ritual/issues/new"));
                        debugPrint("launching browser link");
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  // Function to show the restart confirmation dialog
  void _restartAlert() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal with the back button
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Restart Confirmation'),
          content: const Text('Please maunally restart the app to sync the data'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Close the dialog and restart the app
                Navigator.of(context).pop();
                // Restart.restartApp();
              },
              child: const Text('Ok!'),
            ),
          ],
        );
      },
    );
  }

  void _snackBar(String message, {Color backgroundColor = Colors.blueGrey}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  // Function to show the restart confirmation dialog
  void _deleteForever() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal with the back button
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Permanently'),
          content: const Text('All your data will be lost. Are you sure?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                try {
                  // Delete Card Backgrounds
                  final appDirPath =
                      (await getApplicationDocumentsDirectory()).path;
                  Directory("$appDirPath/images").deleteSync(recursive: true);
                } catch (_) {
                  debugPrint("No user images to delete");
                }

                // Reset SharedPreferences
                _deleteSharedPrefs();

                // Close the dialog and restart the app
                await Boxes.getBox().deleteFromDisk();
                await Restart.restartApp();

                debugPrint("Deleted everything");
              },
              child: const Text('Delete Permanently!'),
            ),
            TextButton(
              onPressed: () {
                // Close the dialog and restart the app
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  /// Reset values in SharedPreferences
  void _deleteSharedPrefs() {
    final sharedPrefMan = SharedPreferencesManager();

    sharedPrefMan.setFileSequence(0);
    sharedPrefMan.setShowHighlight(true);
    sharedPrefMan.setShowSprints(true);
  }
}
