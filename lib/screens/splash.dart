import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:Ritual/services/registry.dart';
import 'package:Ritual/model/ritual.dart';

import 'package:Ritual/screens/home.dart';

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

    // Navigate to the home page
    // Navigator.pushReplacement(context, "/home");
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

/*
class Splash extends StatelessWidget {
  const Splash({super.key});

  // Application Setup
  Future initApp(BuildContext context) async{
    WidgetsFlutterBinding.ensureInitialized();

    await Hive.initFlutter();
    Hive.registerAdapter(RitualAdapter());

    // Open hive database
    await Hive.openBox<Ritual>(Registry.hiveFileName);

    // Navigate to the home page
    Navigator.pushReplacement(context, "/home");
  }

  @override
  Widget build(BuildContext context){
    initApp(context);
    return Scaffold(
      body: SafeArea(child: Center(child: Image.asset("assets/icons/icon.png"))),
    );
  }
}*/