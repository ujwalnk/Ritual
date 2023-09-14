import 'package:flutter/material.dart';

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
    },

    theme: ThemeData(
      useMaterial3: true,
      primarySwatch: Colors.blue
    ),

  ));
}
