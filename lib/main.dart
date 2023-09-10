import 'package:flutter/material.dart';

// Database
import 'package:hive_flutter/hive_flutter.dart';

// Screens
import 'package:Ritual/screens/home.dart';
import 'package:Ritual/screens/ritual.dart';
import 'package:Ritual/screens/settings.dart';
import 'package:Ritual/screens/splash.dart';

// Commit Screens
import 'package:Ritual/screens/commit/habit.dart';
import 'package:Ritual/screens/commit/highlight.dart';
import 'package:Ritual/screens/commit/ritual.dart';
import 'package:Ritual/screens/commit/sprint.dart';

// Services
import 'package:Ritual/services/registry.dart';
import 'package:Ritual/model/ritual.dart';

void main() async {
  // TODO: Move all below code to splash screen
  // WidgetsFlutterBinding.ensureInitialized();

  // await Hive.initFlutter();
  // Hive.registerAdapter(RitualAdapter());

  // // open the hive database
  // await Hive.openBox<Ritual>(Registry.hiveFileName);

  // TODO: Remove expired highlights and sprints 
  

  // TODO: Uncheck expired habits

  runApp(MaterialApp(

    // App initialization during splash
    initialRoute: "/splash",

    routes:{
      "/splash": (context) => const Splash(), // Loading Screen
      "/home": (context) => const Home(), // Default page
      "/settings": (context) => const Settings(),
      "/rituals": (context) => const Rituals(),

      // Commit Screens
      "/commit/habit": (context) => const Commit2Habit(),
      "/commit/highlight": (context) => const Commit2Highlight(),
      "/commit/ritual": (context) => const Commit2Ritual(),
      "/commit/sprint": (context) => const Commit2Sprint(),
    },

    theme: ThemeData(
      useMaterial3: true,
      primarySwatch: Colors.blue
    ),

  ));
}
