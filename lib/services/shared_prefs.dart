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

  static const String showHighlight = 'a';
  static const String showSprints = 'b';
  static const String twoDayRule = 'c';
  static const String fileSequence = 'd';
  static const String appMode = 'e';
  static const String colorizeHabitText = 'f';
  static const String saturateCards = 'g';
  static const String accentColor = 'h';

  // Initialize SharedPreferences asynchronously
  Future<void> init() async {
    _prefs = await _initPrefs();
  }

  // Private method to initialize SharedPreferences
  Future<SharedPreferences> _initPrefs() async {
    return await SharedPreferences.getInstance();
  }

  /// Display Highlights
  bool getShowHighlight() {
    return _prefs.getBool(showHighlight) ?? true;
  }

  Future<void> setShowHighlight(bool value) async {
    await _prefs.setBool(showHighlight, value);
  }

  /// Display Sprints
  bool getShowSprints() {
    return _prefs.getBool(showSprints) ?? true;
  }

  Future<void> setShowSprints(bool value) async {
    await _prefs.setBool(showSprints, value);
  }

  /// Two Day Rule
  bool getTwoDayRule() {
    return _prefs.getBool(twoDayRule) ?? false;
  }

  Future<void> setTwoDayRule(bool value) async {
    await _prefs.setBool(twoDayRule, value);
  }

  /// File Numbering for stored files
  int getFileSequence() {
    return _prefs.getInt(fileSequence) ?? 0;
  }

  Future<void> setFileSequence(int value) async {
    await _prefs.setInt(fileSequence, value);
  }

  /// File Numbering for stored files
  int getAppMode() {
    return _prefs.getInt(appMode) ?? 0;
  }

  Future<void> setAppMode(int value) async {
    await _prefs.setInt(appMode, value);
  }

  /// Colorize Habit Text
  bool getColorizeHabitText() {
    return _prefs.getBool(colorizeHabitText) ?? true;
  }

  Future<void> setColorizeHabitText(bool value) async {
    await _prefs.setBool(colorizeHabitText, value);
  }

  /// Saturate Ritual Cards
  bool getSaturateCard() {
    return _prefs.getBool(saturateCards) ?? true;
  }

  Future<void> setSaturateCard(bool value) async {
    await _prefs.setBool(saturateCards, value);
  }

  /// App Accent Color
  int getAccentColor() {
    return _prefs.getInt(accentColor) ?? 0xFFFFEB3B;
  }

  Future<void> setAccentColor(int value) async {
    await _prefs.setInt(accentColor, value);
  }
}
