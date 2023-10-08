import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Services
import 'package:ritual/services/data_shuttle.dart';
import 'package:ritual/services/shared_prefs.dart';

import 'package:ritual/services/boxes.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Settings",
            style: TextStyle(color: Colors.white, fontFamily: "NotoSans-Light"),
          ),
          backgroundColor: Colors.blue[800],
          elevation: 1,
        ),
        body: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: <Widget>[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Display",
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
                    const Text("Show Highlights",
                        style: TextStyle(fontFamily: "NotoSans-Light")),
                    Checkbox(
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
                      onChanged: (value) async {
                        await SharedPreferencesManager().setShowSprints(value!);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
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
              SizedBox(
                width: double.infinity,
                child: TextButton(
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Export",
                          style: TextStyle(fontFamily: "NotoSans-Light")),
                      Icon(Icons.upload_file_rounded),
                    ],
                  ),
                ),
              ),
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

                        // Show a confirmation dialog to restart the app
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Import",
                          style: TextStyle(fontFamily: "NotoSans-Light")),
                      Icon(Icons.download_rounded),
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
              const SizedBox(
                height: 20,
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
          content: const Text('We need to restart the app to sync the data'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Close the dialog and restart the app
                // Navigator.of(context).pop();
                Restart.restartApp();
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
                try{
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
