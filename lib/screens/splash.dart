import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:ritual/services/registry.dart';
import 'package:ritual/model/ritual.dart';

import 'package:ritual/screens/home.dart';

import 'package:ritual/services/boxes.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  // This flag will be used to track whether initialization is complete
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Call your async initialization method here
    initApp().then((_) {
      setState(() {
        _isInitialized = true;
      });
    });
  }

  // Application Setup
  Future<void> initApp() async {
    await Hive.initFlutter();
    Hive.registerAdapter(RitualAdapter());

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
          // Delete Expired Sprint & Highlight
          boxes.delete(key);
        }
      }
    }

    // Navigate to the home page
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const Home(), // Replace with your home page widget
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