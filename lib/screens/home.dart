import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Home",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[600],
        shadowColor: Colors.blue[400],
        elevation: 2,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          )
        ],
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 16.0, 0, 16.0),
          child: Text(
            "Highlight",
            style: TextStyle(fontSize: 28, fontFamily: "NotoSans-Light"),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 16.0, 0, 16.0),
          child: Text(
            "Sprint",
            style: TextStyle(fontSize: 28, fontFamily: "NotoSans-Light"),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 16.0, 0, 16.0),
          child: Text(
            "Ritual",
            style: TextStyle(fontSize: 28, fontFamily: "NotoSans-Light"),
          ),
        ),
      ]),
    );
  }
}
