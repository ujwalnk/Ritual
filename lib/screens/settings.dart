import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
  padding: const EdgeInsets.all(18.0),
  child: Column(
    children: <Widget>[
      // Check box for Highlight
      Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("Show Highlights"),
            Checkbox(
              value: false,
              onChanged: (value) => {},
            ),
          ],
        ),
      ),

      // Check box for Sprint
      Align(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("Show Sprints"),
            Checkbox(
              value: false,
              onChanged: (value) => {},
            ),
          ],
        ),
      ),
    ],
  ),
)

    );
  }
}