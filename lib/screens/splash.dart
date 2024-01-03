import 'dart:io';

import 'package:flutter/material.dart';

// Hive imports
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ritual/model/ritual.dart';

// Screens
import 'package:ritual/screens/getting_started.dart';
import 'package:ritual/screens/home.dart';

// Services
import 'package:ritual/services/boxes.dart';
import 'package:ritual/services/registry.dart';
import 'package:ritual/services/constants.dart';
import 'package:ritual/services/shared_prefs.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    initApp().then((_) {
      setState(() {});
    });
  }

  // Application Setup
  Future<void> initApp() async {
    // Open hive database
    await Hive.initFlutter();
    Hive.registerAdapter(RitualAdapter());
    await Hive.openBox<Ritual>(Registry.hiveFileName);

    final boxes = Boxes.getBox();
    for (var key in boxes.keys) {
      debugPrint(
          "@splash: Iterating through: $key > ${boxes.get(key)?.expiry} =? ${DateTime.now()}");
      if (DateTime.now().isAfter(boxes.get(key)?.expiry ?? DateTime.now())) {
        debugPrint(
            "@splash: Expired: ${boxes.get(key)?.url} ${boxes.get(key)?.type} ${boxes.get(key)?.expiry}");
        if (boxes.get(key)?.type!.contains("habit") ?? false) {
          // Uncheck Expired Habits
          boxes.get(key)?.complete = 0;
        } else if (boxes.get(key)?.type == Constants.typeSprint ||
            boxes.get(key)?.type == Constants.typeHLight) {
          // Delete the stored Image file on highlight & Sprint Expiration
          if ((boxes.get(key)?.background?.isNotEmpty ?? false) &&
              boxes.get(key)?.background != Constants.noBackground) {
            File(boxes.get(key)?.background ?? '').delete();
          }

          // Delete Expired Sprint & Highlight
          boxes.delete(key);
        }
      }
      
      // Uncheck habits based on checkedOn field the next day
      else if ((boxes.get(key)?.checkedOn?.isBefore(DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day)) ??
              false) &&
          (boxes.get(key)?.type!.contains(Constants.typeHabits) ?? false)) {
        boxes.get(key)!.complete = 0;
        boxes.get(key)!.save();
      }
      // Uncheck sprints based on checkedOn field the next day
      else if ((boxes.get(key)?.checkedOn?.isBefore(DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day)) ??
              false) &&
          (boxes.get(key)?.type!.contains(Constants.typeSprint) ?? false)) {
        boxes.get(key)!.complete = 0;
        boxes.get(key)!.save();
      }
    }

    debugPrint("Date today: ${DateTime.now().day}");

    bool shouldnavigateHome = SharedPreferencesManager().getAppInit();

    // Navigate to the home page if appInit otherwise to GettingStarted 
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => shouldnavigateHome ? const Home() : const GettingStarted(),
      settings: RouteSettings(name: shouldnavigateHome ? "Home" : "Getting Started"),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while initializing
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Image.asset(
              "assets/icons/icon.png"),
        ),
      ),
    );
  }
}
