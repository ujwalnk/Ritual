import 'dart:io';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

// Service
import 'package:ritual/services/boxes.dart';
import 'package:ritual/services/registry.dart';

Future<void> backupHiveBox<T>(String backupPath) async {
  final box = Boxes.getBox();
  final boxPath = box.path;

  try {
    File(boxPath!).copy("$backupPath/ritual-${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}.bkp");
  } catch (_){
    debugPrint("@data_shuttle: Export Exception Caught: $_");
  }
}

Future<void> restoreHiveBox<T>(String backupPath) async {
  final box = Boxes.getBox();
  final boxPath = box.path;
  await box.close();

  try {
    File(backupPath).copy(boxPath!);
  } finally {
    await Hive.openBox<T>(Registry.hiveFileName);
  }
}