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
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    // RoboStem alliances structure
    final alliances = json['alliances'] as Map<String, dynamic>?;
    final red = alliances?['red'] as Map<String, dynamic>?;
    final blue = alliances?['blue'] as Map<String, dynamic>?;

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
    );
  }

  Map<String, dynamic> toJson() => _$MatchModelToJson(this);
}
