import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'match_model.g.dart';

@HiveType(typeId: 2, adapterName: 'MatchAdapter')
@JsonSerializable()
class MatchModel {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final int eventId;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final int round;
  @HiveField(4)
  final int instance;
  @HiveField(5)
  final int matchNum;
  @HiveField(6)
  final List<int> redAllianceTeamIds;
  @HiveField(7)
  final List<int> blueAllianceTeamIds;
  @HiveField(8)
  final DateTime? scheduledTime;
  @HiveField(9)
  final int? redScore;
  @HiveField(10)
  final int? blueScore;
  @HiveField(11)
  final String? winner;
  @HiveField(12)
  final List<String> redAllianceTeamNums;
  @HiveField(13)
  final List<String> blueAllianceTeamNums;
  @HiveField(14)
  final int? divisionId;

  MatchModel({
    required this.id,
    required this.eventId,
    required this.name,
    required this.round,
    required this.instance,
    required this.matchNum,
    this.redAllianceTeamIds = const [],
    this.blueAllianceTeamIds = const [],
    this.redAllianceTeamNums = const [],
    this.blueAllianceTeamNums = const [],
    this.scheduledTime,
    this.redScore,
    this.blueScore,
    this.winner,
    this.divisionId,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    // RobotEvents v2 alliances structure is a List of Maps
    // "alliances": [{"color": "blue", "score": 10, "teams": [...]}, {"color": "red", "score": 20, "teams": [...]}]
    final alliancesList = json['alliances'] as List?;
    Map<String, dynamic>? red;
    Map<String, dynamic>? blue;

    if (alliancesList != null) {
      for (final a in alliancesList) {
        if (a['color'] == 'red') red = a as Map<String, dynamic>;
        if (a['color'] == 'blue') blue = a as Map<String, dynamic>;
      }
    }

    final redTeams = (red?['teams'] as List?)
            ?.map((t) => (t['team']['id'] as int))
            .toList() ??
        [];
    final blueTeams = (blue?['teams'] as List?)
            ?.map((t) => (t['team']['id'] as int))
            .toList() ??
        [];

    final redTeamNums = (red?['teams'] as List?)
            ?.map((t) => (t['team']['name'] as String))
            .toList() ??
        [];
    final blueTeamNums = (blue?['teams'] as List?)
            ?.map((t) => (t['team']['name'] as String))
            .toList() ??
        [];

    final rScore = red?['score'] as int?;
    final bScore = blue?['score'] as int?;

    String? winner;
    if (rScore != null && bScore != null) {
      if (rScore > bScore)
        winner = 'red';
      else if (bScore > rScore)
        winner = 'blue';
      else
        winner = 'tie';
    }

    return MatchModel(
      id: json['id'].hashCode,
      eventId: json['event'] != null ? (json['event']['id'] as int) : 0,
      name: json['name'] as String? ?? 'Match',
      round: json['round'] as int,
      instance: json['instance'] as int,
      matchNum: json['matchnum'] as int,
      redAllianceTeamIds: redTeams,
      blueAllianceTeamIds: blueTeams,
      redAllianceTeamNums: redTeamNums,
      blueAllianceTeamNums: blueTeamNums,
      scheduledTime: json['scheduled'] != null
          ? DateTime.tryParse(json['scheduled'])
          : null,
      redScore: rScore,
      blueScore: bScore,
      winner: winner,
      divisionId: json['division'] != null
          ? (json['division'] is int
              ? json['division']
              : (json['division'] as Map)['id'] as int)
          : null,
    );
  }

  DateTime get safeScheduledTime => scheduledTime ?? DateTime(2099);

  String get shortName {
    // "TeamWork #33" -> "Q33"
    // "Match #1-1" or "Final #1-1" -> "F 1"
    // RobotEvents names are like "TeamWork #33", "Final #1-1"

    // Check for Qualification matches
    if (name.contains('TeamWork') ||
        name.contains('Qualification') ||
        name.contains('Q')) {
      final number = name.split('#').last.trim();
      return 'Q$number';
    }

    // Check for Finals
    if (name.contains('Final') ||
        name.contains('F') ||
        name.contains('Match #')) {
      // Often "Match #1-1" in older events or "Final #1-1"
      // User wants "F [match number]"? Or usually Finals are just "F 1", "F 2"...
      // In VEX IQ, finals are just one round usually, match 1 to N.
      // Let's grab the numbers.
      // If "Match #1-1", maybe "F 1".
      final parts = name.split('#');
      if (parts.length > 1) {
        // If it looks like "1-1", takes the last part? Or just the whole thing?
        // User said: "#1-1 -> F 1".
        // If it is 1-1, let's just take the first number if they are same?
        // Actually typically "1-1" means Round 1 Match 1.
        // Let's simplify to "F " + instance/matchnum.

        // Use the matchNum property if available and meaningful?
        // matchNum is 1, 2, ...
        return 'F $matchNum';
      }
    }

    return name;
  }

  bool get isQualifier =>
      round ==
      2; // RobotEvents round 2 is usually Quals. Round 3, 4, 15 etc are others.
  // Actually, VEX IQ usually: Round 2 = Quals (Teamwork), Round 15? = Finals.
  // Let's assume anything NOT round 2 is likely finals or practice.
  // But safer to check name or round type.
  // Let's use:
  // Round 1 = Practice
  // Round 2 = Qualification (Teamwork)
  // Round 3 = Quarterfinals (VRC)
  // Round 4 = Semifinals (VRC)
  // Round 5 = Finals
  // Round 15 = Finals (VEX IQ sometimes?)

  // For VEX IQ:
  // "TeamWork" matches are Quals.
  // "Finals" are Finals.

  bool get isFinals => !isQualifier && !name.contains('Practice');

  Map<String, dynamic> toJson() => _$MatchModelToJson(this);
}
