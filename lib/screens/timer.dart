/// Code from: https://medium.flutterdevs.com/creating-a-countdown-timer-using-animation-in-flutter-2d56d4f3f5f1

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:keep_screen_on/keep_screen_on.dart';

// Hive Model
import 'package:ritual/model/ritual.dart';

// Services
import 'package:ritual/services/boxes.dart';
import 'package:ritual/services/constants.dart';
import 'package:ritual/services/misc.dart';
import 'package:ritual/services/shared_prefs.dart';

class Timer extends StatefulWidget {
  const Timer({super.key});

  @override
  _TimerState createState() => _TimerState();
}

class _TimerState extends State<Timer> with TickerProviderStateMixin {
  late AnimationController controller;
  bool init = false;

  // Run all habits in the ritual
  bool runRitual = false;

  String get timerString {
    Duration duration = controller.duration! * controller.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Get data from parent screen
    Map data = ModalRoute.of(context)?.settings.arguments as Map;

    debugPrint("Data @Timer: $data");

    // Set ScreenTimeOut
    if (SharedPreferencesManager().getScreenTimeout()) {
      KeepScreenOn.turnOff();
    } else {
      KeepScreenOn.turnOn();
    }

    // init
    if (!init) {
      // Set duration
      controller = AnimationController(
          vsync: this,
          duration: Duration(minutes: data['ritual'].duration.toInt()),
          value: 1.0);
      init = true;
    }

    ThemeData themeData = Theme.of(context);
    return WillPopScope(
      // On Screen Exit, clear screenTimeout
      onWillPop: () async {
        KeepScreenOn.turnOff();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          // Add an IconButton at the top right corner
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  bool isScreenTimeout = !SharedPreferencesManager().getScreenTimeout();
                  SharedPreferencesManager().setScreenTimeout(
                      isScreenTimeout);
                  Misc.showAutoDismissSnackBar(context, isScreenTimeout ? "Screen will turnoff automatically" : "Screen will stay on until timer exit");
                  setState(() {});
                },
                icon: Icon(SharedPreferencesManager().getScreenTimeout()
                    ? Icons.lock_clock
                    : Icons.access_time)),
          ],
        ),
        backgroundColor: Colors.black,
        floatingActionButton: Visibility(
          visible: !runRitual,
          child: FloatingActionButton(
            onPressed: (){
              runRitual = true;

              // TODO: Run through all habits in the ritual one by one in the timer screen
            },
            child: const Icon(Icons.fast_forward_rounded)
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return Stack(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Align(
                              alignment: FractionalOffset.center,
                              child: AspectRatio(
                                aspectRatio: 1.0,
                                child: Stack(
                                  children: <Widget>[
                                    Positioned.fill(
                                      child: CustomPaint(
                                          painter: CustomTimerPainter(
                                        animation: controller,
                                        backgroundColor: Colors.white,
                                        color: themeData.indicatorColor,
                                      )),
                                    ),
                                    Align(
                                      alignment: FractionalOffset.center,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            data['ritual']
                                                .url
                                                .toString()
                                                .substring(data['ritual']
                                                        .url
                                                        .toString()
                                                        .lastIndexOf("/") +
                                                    1),
                                            style: const TextStyle(
                                                fontSize: 20.0,
                                                color: Colors.white),
                                          ),
                                          Text(
                                            timerString,
                                            style: const TextStyle(
                                                fontSize: 112.0,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          AnimatedBuilder(
                              animation: controller,
                              builder: (context, child) {
                                if (controller.value == 0) {
                                  // Notify user on TimeUp - Double Ping
                                  FlutterRingtonePlayer.playNotification();
                                  FlutterRingtonePlayer.playNotification();

                                  // Mark Habit as Complete and save into hive
                                  Ritual r =
                                      Boxes.getBox().get(data['ritual'].key)!;
                                  r.complete = 1;
                                  r.checkedOn = DateTime.now();
                                  r.save();

                                  // Return to Rituals screen
                                  Navigator.pop(context);
                                }
                                return FloatingActionButton(
                                  onPressed: () {
                                    if (controller.isAnimating) {
                                      controller.stop();
                                    } else {
                                      // Ping on timer start
                                      FlutterRingtonePlayer.playNotification();

                                      controller.reverse(
                                          from: controller.value == 0.0
                                              ? 1.0
                                              : controller.value);
                                    }
                                    setState(() {});
                                  },
                                  backgroundColor: Constants.primaryColor,
                                  child: Icon(
                                      controller.isAnimating
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Color(SharedPreferencesManager()
                                          .getAccentColor())),
                                );
                              }),
                        ],
                      ),
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }
}

class CustomTimerPainter extends CustomPainter {
  CustomTimerPainter({
    required this.animation,
    required this.backgroundColor,
    required this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = Colors.green;
    double progress = (1.0 - animation.value) * 2 * pi;
    canvas.drawArc(Offset.zero & size, pi * 1.5, -progress, false, paint);
  }

  @override
  bool shouldRepaint(CustomTimerPainter oldDelegate) {
    return animation.value != oldDelegate.animation.value ||
        color != oldDelegate.color ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
