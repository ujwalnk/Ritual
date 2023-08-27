import 'package:flutter/material.dart';

// Database
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:ritual/model/ritual.dart';

// Screens
import 'package:ritual/screens/splash.dart';

// Services


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(RitualAdapter());

  runApp(MaterialApp(

    initialRoute: "/splash",

    routes:{
      "/splash": (context) => const Splash(),
    }
  ));
}
