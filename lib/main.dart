import 'package:flutter/material.dart';

// Database
import 'package:hive_flutter/hive_flutter.dart';

import 'package:Ritual/model/ritual.dart';

// Screens
import 'package:Ritual/screens/splash.dart';
import 'package:Ritual/screens/home.dart';
import 'package:Ritual/screens/settings.dart';
import 'package:Ritual/screens/ritual.dart';

// Commit Screens
import 'package:Ritual/screens/commit/ritual.dart';
import 'package:Ritual/screens/commit/highlight.dart';
import 'package:Ritual/screens/commit/sprint.dart';
import 'package:Ritual/screens/commit/habit.dart';

// Services
import 'package:Ritual/services/registry.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(RitualAdapter());

  // open the hive database
  await Hive.openBox<Ritual>(Registry.hiveFileName);

  runApp(MaterialApp(

    initialRoute: "/home",

    routes:{
      "/splash": (context) => const Splash(),
      "/home": (context) => const Home(),
      "/settings": (context) => const Settings(),
      "/rituals": (context) => const Rituals(),

      // Commit Screen
      "/commit/ritual": (context) => const Commit2Ritual(),
      "/commit/highlight": (context) => const Commit2Highlight(),
      "/commit/sprint": (context) => const Commit2Sprint(),
      "/commit/habit": (context) => const Commit2Habit(),
    },

    theme: ThemeData(
      useMaterial3: true,
      primarySwatch: Colors.blue
    ),

  ));
}
