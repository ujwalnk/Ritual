import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spotlight_ant/spotlight_ant.dart';

// Hive database packages
import 'package:ritual/model/ritual.dart';

// Services
import 'package:ritual/services/boxes.dart';
import 'package:ritual/services/constants.dart';
import 'package:ritual/services/shared_prefs.dart';
import 'package:ritual/services/widgets/image_picker.dart';

class Commit2Highlight extends StatefulWidget {
  const Commit2Highlight({super.key});

  @override
  State<Commit2Highlight> createState() => _Commit2HighlightState();
}

class _Commit2HighlightState extends State<Commit2Highlight> {
  final TextEditingController _textFieldController = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();

  // Accent color
  final Color accentColor = Color(SharedPreferencesManager().getAccentColor());

  // Card Background illustration path
  String cardBackgroundPath = Constants.noBackground;

  // Check for highlight plans for the next day
  bool highlight4Today = true;

  // Map of asset Illustrations
  Map cardIllustrations = {};

  // Enable spotlight
  bool spotlightActivate = false;

  @override
  Widget build(BuildContext context) {
    // Get data from parent screen
    Map data = ModalRoute.of(context)?.settings.arguments as Map;

    // Focus the textField
    if(SharedPreferencesManager().getAppInit() <= 1){
      _textFieldFocusNode.requestFocus();
      spotlightActivate = true;
      SharedPreferencesManager().setAppInit(2);
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

    return SpotlightShow(
      child: Scaffold(
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

                        // Delete the user image
                        if (data['ritual'].background !=
                            Constants.noBackground) {
                          await File(data['ritual'].background).delete();
                        }

                        deleteHighlight(data['ritual']);
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
                SpotlightAnt(
                  enable: spotlightActivate,
                  content: spotlightText("Enter your highlight for the Day"),
                  child: TextField(
                    controller: _textFieldController,
                    focusNode: _textFieldFocusNode,
                    onChanged: (text) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: data['mode'] == "edit"
                            ? "Rename your Highlight ${data['uri'].replaceFirst('/', '')} to"
                            : "What's your latest Highlight"),
                  ),
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
                    Row(children: [
                      SpotlightAnt(
                        enable: spotlightActivate,
                        content:
                            spotlightText("Choose from the best illustrations"),
                        child: IconButton(
                          icon: Icon(
                            Icons.image,
                            color: accentColor,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CustomImagePicker(
                                  onImageSelected: (String selectedImage) {
                                    cardBackgroundPath = selectedImage;
                                    debugPrint(
                                        "@ritual: Image selected: $selectedImage");
                                  },
                                  cardIllustrations: cardIllustrations,
                                );
                              },
                            );
                          },
                        ),
                      ),
                      SpotlightAnt(
                        enable: spotlightActivate,
                        content: spotlightText("Pick your favourite image"),
                        child: IconButton(
                          icon: Icon(
                            Icons.image_search,
                            color: accentColor,
                          ),
                          onPressed: () => _getImage(data),
                        ),
                      ),
                      SpotlightAnt(
                        enable: spotlightActivate,
                        content: spotlightText(
                            "Let go with the default illustration"),
                        child: IconButton(
                          icon: Icon(
                            Icons.broken_image,
                            color: accentColor,
                          ),
                          onPressed: () =>
                              cardBackgroundPath = Constants.noBackground,
                        ),
                      ),
                    ])
                  ],
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const Text("Tomorrow's Highlight",
                          style: TextStyle(
                              fontSize: 20, fontFamily: "NotoSans-Light")),
                      SpotlightAnt(
                        enable: spotlightActivate,
                        content: spotlightText("Planning the highlight for tomorrow?"),
                        child: Checkbox(
                          activeColor: accentColor,
                          value: highlight4Today,
                          onChanged: (value) async {
                            highlight4Today = !value!;
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Visibility(
                      visible: (_textFieldController.text.isNotEmpty ||
                              data["mode"] == "edit") &&
                          !(_textFieldController.text.contains("/")),
                      child: FilledButton.tonal(
                        onPressed: () {
                          if (data['mode'] == "new") {
                            DateTime now = DateTime.now();
                            final ritual = Ritual()
                              ..complete = 0
                              ..url = "/${_textFieldController.text}"
                              ..background = cardBackgroundPath
                              ..type = Constants.typeHLight
                              // Highlight expires the next day
                              ..expiry = DateTime(
                                  now.year, now.month, now.day, 0, 0, 0, 0).add(Duration(days:highlight4Today ?  1 : 2));

                            final box = Boxes.getBox();
                            box.add(ritual);
                          } else {
                            Ritual r = data['ritual'];

                            if (_textFieldController.text.isNotEmpty) {
                              r.url = "/${_textFieldController.text}";
                            }

                            if ((cardBackgroundPath != r.background) &&
                                (cardBackgroundPath.isNotEmpty)) {
                              r.background = cardBackgroundPath;
                            }

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
          )),
    );
  }

  void deleteHighlight(Ritual r) {
    Boxes.getBox().delete(r.key);
    Boxes.getBox().flush();

    Navigator.pop(context);
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
            (data["background"] != Constants.noBackground)) {
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
      cardBackgroundPath = Constants.noBackground;
    }
  }

  Widget spotlightText(String text) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: Align(alignment: Alignment.bottomCenter, child: Text(text)));
  }
}
