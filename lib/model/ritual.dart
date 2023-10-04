import 'package:hive/hive.dart';

part 'ritual.g.dart';

@HiveType(typeId: 0)
class Ritual extends HiveObject{
  // Percentage of habit complete
  @HiveField(0)
  double complete = 0;

  // Path to the habit
  @HiveField(1)
  String url = "";

  // Background image of Ritual only
  @HiveField(2)
  String? background;

  // Reminder Time for Ritual
  // TODO: Duration Time for Habit
  @HiveField(3)
  String? time;

  // Type of Habit
  @HiveField(4)
  String? type;

  // Expiry for Sprints and Highlights
  @HiveField(5)
  DateTime? expiry;

  // Habit Position in the Ritual screen
  @HiveField(6)
  int? position;

  // Habit priority
  @HiveField(7)
  int priority = 4;

  // Creation Date for 1% habits
  DateTime? createdOn;
}