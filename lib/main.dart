import 'package:flutter/material.dart';

// Database
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:ritual/model/ritual.dart';

// Screens
import 'package:ritual/screens/splash.dart';
import 'package:ritual/screens/home.dart';
import 'package:ritual/screens/settings.dart';

// Services


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(RitualAdapter());

  runApp(MaterialApp(

    initialRoute: "/home",

    routes:{
      "/splash": (context) => const Splash(),
      "/home": (context) => const Home(),
      "/settings": (context) => const Settings(),
    },

    theme: ThemeData(
      useMaterial3: true,
      primarySwatch: Colors.blue
    ),

  ));
}
