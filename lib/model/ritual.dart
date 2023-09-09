import 'package:hive/hive.dart';

part 'ritual.g.dart';

@HiveType(typeId: 0)
class Ritual extends HiveObject{
  @HiveField(0)
  // Percentage of habit complete
  double complete = 0;

  @HiveField(1)
  // Path to the habit
  String url = "";

  @HiveField(2)
  // Background image of Ritual only
  String? background;

  @HiveField(3)
  // Reminder Time for Ritual
  // TODO: Duration Time for Habit
  String? time;

  @HiveField(4)
  // Type of Habit
  String? type;

  @HiveField(5)
  // Expiry for Sprints and Highlights
  DateTime? expiry;
}