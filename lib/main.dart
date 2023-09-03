import 'package:flutter/material.dart';

// Database
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:Ritual/model/ritual.dart';

// Screens
import 'package:Ritual/screens/splash.dart';
import 'package:Ritual/screens/home.dart';
import 'package:Ritual/screens/settings.dart';

// Commit Screens
import 'package:Ritual/screens/commit/ritual.dart';
import 'package:Ritual/screens/commit/highlight.dart';
import 'package:Ritual/screens/commit/sprint.dart';

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

      // Commit Screen
      "/commit/ritual": (context) => const commit2Ritual(),
      "/commit/highlight": (context) => const commit2Highlight(),
      "/commit/sprint": (context) => const commit2Sprint(),
    },

    theme: ThemeData(
      useMaterial3: true,
      primarySwatch: Colors.blue
    ),

  ));
}
