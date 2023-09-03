import 'package:hive/hive.dart';

import 'package:Ritual/model/ritual.dart';

// Services
import 'package:Ritual/services/registry.dart';

class Boxes {
  static Box<Ritual> getRituals() =>
    Hive.box<Ritual>(Registry.hiveFileName);

}