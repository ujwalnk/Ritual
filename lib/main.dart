import 'package:flutter/material.dart';
import 'package:ritual/screens/splash.dart';

void main() {
  runApp(MaterialApp(

    initialRoute: "/splash",

    routes:{
      "/splash": (context) => const Splash(),
    }
  ));
}
