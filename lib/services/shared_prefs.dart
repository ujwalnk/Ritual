import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {
  // Singleton instance
  static final SharedPreferencesManager _instance =
      SharedPreferencesManager._internal();

  late SharedPreferences _prefs;

  factory SharedPreferencesManager() {
    return _instance;
  }

  SharedPreferencesManager._internal();

  // Initialize SharedPreferences asynchronously
  Future<void> init() async {
    _prefs = await _initPrefs();
  }

  // Private method to initialize SharedPreferences
  Future<SharedPreferences> _initPrefs() async {
    return await SharedPreferences.getInstance();
  }

  bool getShowHighlight() {
    return _prefs.getBool('show_highlight') ?? true;
  }

  Future<void> setShowHighlight(bool value) async {
    await _prefs.setBool('show_highlight', value);
  }

  bool getShowSprints() {
    return _prefs.getBool('show_sprints') ?? true;
  }

  Future<void> setShowSprints(bool value) async {
    await _prefs.setBool('show_sprints', value);
  }

  bool getTwoDayRule() {
    return _prefs.getBool('two_day_rule') ?? false;
  }

  Future<void> setTwoDayRule(bool value) async {
    await _prefs.setBool('two_day_rule', value);
  }

  /// File Numbering for stored files
  int getFileSequence() {
    return _prefs.getInt('file_sequence') ?? 0;
  }

  Future<void> setFileSequence(int value) async {
    await _prefs.setInt('file_sequence', value);
  }

  /// App Accent Color
  int getAccentColor() {
    return _prefs.getInt('accent_color') ?? 0xFFFFEB3B;
  }

  Future<void> setAccentColor(int value) async {
    await _prefs.setInt('accent_color', value);
  }
}
