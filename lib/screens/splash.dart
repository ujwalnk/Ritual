import 'dart:io';

import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';

import 'package:ritual/model/ritual.dart';

// Screens
import 'package:ritual/screens/home.dart';


// Services
import 'package:ritual/services/boxes.dart';
import 'package:ritual/services/registry.dart';
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
      setState(() {
        // Setstate to Navigate to home screen here
      });
    });
  }

  // Application Setup
  Future<void> initApp() async {
    await Hive.initFlutter();
    Hive.registerAdapter(RitualAdapter());

    await SharedPreferencesManager().init();

    // Open hive database
    await Hive.openBox<Ritual>(Registry.hiveFileName);

    final boxes = Boxes.getBox();
    for (var key in boxes.keys) {
      debugPrint("@splash: Iterating through: $key > ${boxes.get(key)?.expiry} =? ${DateTime.now()}");
      if (DateTime.now().isAfter(boxes.get(key)?.expiry ?? DateTime.now())) {
        debugPrint("@splash: Expired: ${boxes.get(key)?.url} ${boxes.get(key)?.type} ${boxes.get(key)?.expiry}");
        if(boxes.get(key)?.type == "habit"){
          // Uncheck Expired Habits
          boxes.get(key)?.complete = 0;
        } else if(boxes.get(key)?.type == "sprint" || boxes.get(key)?.type == "highlight"){
          // Delete the stored Image file
          if((boxes.get(key)?.background?.isNotEmpty ?? false) && boxes.get(key)?.background != "default"){
            File(boxes.get(key)?.background ?? '').delete();
          }
          
          // Delete Expired Sprint & Highlight
          boxes.delete(key);
        }
      }
    }

    // Navigate to the home page
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const Home(), // Replace with your home page widget
      settings: const RouteSettings(name: "Home"),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child:Image.asset("assets/icons/icon.png"), // Show a loading indicator while initializing
        ),
      ),
    );
  }
}