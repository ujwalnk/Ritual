/// Author: Ujwal N K
/// Created On: 2023 Dec, 28
/// Miscellaneous Services

import 'package:flutter/material.dart';
import 'package:ritual/services/constants.dart';
import 'package:ritual/services/shared_prefs.dart';

class Misc {

  // Check for using dark background
  static bool isDark(BuildContext context) {
    debugPrint("Returning: ${(((MediaQuery.of(context).platformBrightness == Brightness.dark) &&
            (SharedPreferencesManager().getAppMode() == Constants.modeAuto)) ||
        (SharedPreferencesManager().getAppMode() == Constants.modeDark))}");
    return (((MediaQuery.of(context).platformBrightness == Brightness.dark) &&
            (SharedPreferencesManager().getAppMode() == Constants.modeAuto)) ||
        (SharedPreferencesManager().getAppMode() == Constants.modeDark));
  }
}
