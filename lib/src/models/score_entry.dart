import 'package:hive/hive.dart';

part 'score_entry.g.dart';

@HiveType(typeId: 4)
class ScoreEntry extends HiveObject {
  @HiveField(0)
  final int connectedPins;
  @HiveField(1)
  final int connectedBeams;
  @HiveField(2)
  final int twoColorStacks;
  @HiveField(3)
  final int threeColorStacks;
  @HiveField(4)
  final int matchingGoalOrBeam;
  @HiveField(5)
  final int standoffGoal;
  @HiveField(6)
  final int clearedStartingPins;
  @HiveField(7)
  final int robotsContacting;
  @HiveField(8)
  final DateTime date;
  @HiveField(9)
  final int totalScore;

  ScoreEntry({
    required this.connectedPins,
    required this.connectedBeams,
    required this.twoColorStacks,
    required this.threeColorStacks,
    required this.matchingGoalOrBeam,
    required this.standoffGoal,
    required this.clearedStartingPins,
    required this.robotsContacting,
    required this.date,
    required this.totalScore,
  });
}
