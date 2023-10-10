import 'package:flutter/material.dart';

// Screens
import 'package:ritual/screens/home.dart';
import 'package:ritual/screens/ritual.dart';
import 'package:ritual/screens/ritual_sort.dart';
import 'package:ritual/screens/settings.dart';
import 'package:ritual/screens/splash.dart';
import 'package:ritual/screens/timer.dart';

// Commit Screens
import 'package:ritual/screens/commit/habit.dart';
import 'package:ritual/screens/commit/highlight.dart';
import 'package:ritual/screens/commit/ritual.dart';
import 'package:ritual/screens/commit/sprint.dart';

void main() async {

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

      // Other Screens
      "/sort/ritual": (context) => const RitualSort(),
      "/timer": (context) => Timer(),
    },

    theme: ThemeData(
      useMaterial3: true,
      primarySwatch: Colors.blue
    ),

  ));
}
