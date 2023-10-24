/// Code from: https://medium.flutterdevs.com/creating-a-countdown-timer-using-animation-in-flutter-2d56d4f3f5f1

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:ritual/model/ritual.dart';
import 'package:ritual/services/boxes.dart';
import 'package:ritual/services/constants.dart';

class Timer extends StatefulWidget {
  @override
  _TimerState createState() => _TimerState();
}

// TODO: On complete show makr complete button instead of play pause
// TODO: Play audio beep at end
class _TimerState extends State<Timer> with TickerProviderStateMixin {
  late AnimationController controller;
  bool init = false;

  String get timerString {
    Duration duration = controller.duration! * controller.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Get data from parent screen
    Map data = ModalRoute.of(context)?.settings.arguments as Map;

    // init
    if (!init) {
      // Set duration
      controller = AnimationController(
          vsync: this,
          duration: Duration(minutes: data['ritual'].duration),
          value: 1.0);
      init = true;
    }

    ThemeData themeData = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
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
                                          data['ritual'].url.toString().substring(data['ritual'].url.toString().lastIndexOf("/") + 1),
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
                                // Notify user on TimeUp
                                FlutterRingtonePlayer.playNotification();
                                
                                // Save Habit as Complete
                                Ritual r = Boxes.getBox().get(data['ritual'].key)!;
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
                                      controller.reverse(
                                          from: controller.value == 0.0
                                              ? 1.0
                                              : controller.value);
                                    }
                                    setState(() {});
                                  },
                                  backgroundColor: Constants.primaryColor,
                                  child: Icon(controller.isAnimating
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                      color: Constants.accentColor),
                                      );
                            }),
                      ],
                    ),
                  ),
                ],
              );
            }),
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
