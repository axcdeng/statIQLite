import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'team_model.g.dart';

@HiveType(typeId: 1, adapterName: 'TeamAdapter')
@JsonSerializable()
class Team {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String number;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String? school;
  @HiveField(4)
  final String? robotName;
  @HiveField(5)
  final int? worldRank;
  @HiveField(6)
  final int eventId;
  @HiveField(7)
  final String? organization;
  @HiveField(8)
  final String? location;
  @HiveField(9)
  final double? trueskill;
  @HiveField(10)
  final double? ccwm;
  @HiveField(11)
  final Map<String, dynamic>? statiq;

  Team({
    required this.id,
    required this.number,
    required this.name,
    this.school,
    this.robotName,
    this.worldRank,
    required this.eventId,
    this.organization,
    this.location,
    this.trueskill,
    this.ccwm,
    this.statiq,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    final locationObj = json['location'] as Map<String, dynamic>?;
    final city = locationObj?['city'] as String?;
    final region = locationObj?['region'] as String?;
    final country = locationObj?['country'] as String?;
    final locationStr = [city, region, country]
        .where((e) => e != null && e.isNotEmpty)
        .join(', ');

    final statiq = json['statiq'] as Map<String, dynamic>?;
    final perf = statiq?['performance'] as num?;

    // Robust ID parsing:
    // 1. Try 'teamId' (integer)
    // 2. Try 'id' if it's an integer
    // 3. If 'id' is a string, hash it or return 0
    int teamId = 0;
    if (json['teamId'] is int) {
      teamId = json['teamId'] as int;
    } else if (json['id'] is int) {
      teamId = json['id'] as int;
    } else {
      // Fallback for string ID: Try parse, else hash or 0
      final idStr = json['id'].toString();
      teamId = int.tryParse(idStr) ?? idStr.hashCode;
    }

    return Team(
      id: teamId,
      number: json['number'] as String,
      name: json['team_name'] as String? ?? json['name'] as String? ?? '',
      school: json['organization'] as String?,
      organization: json['organization'] as String?,
      robotName: json['robot_name'] as String?,
      eventId: 0,
      location: locationStr,
      trueskill: perf?.toDouble(),
      statiq: statiq,
    );
  }

  Map<String, dynamic> toJson() => _$TeamToJson(this);
}
