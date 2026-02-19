import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'team_model.g.dart';

@HiveType(typeId: 1, adapterName: 'TeamAdapter')
@JsonSerializable(createFactory: false)
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
  final Map? statiq;
  @HiveField(12)
  final String? grade;

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
    this.grade,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    dynamic loc = json['location'];
    String? locationStr;
    if (loc is Map) {
      final city = loc['city'] as String?;
      final region = loc['region'] as String?;
      final country = loc['country'] as String?;
      locationStr = [city, region, country]
          .where((e) => e != null && e.isNotEmpty)
          .join(', ');
    } else if (loc is String) {
      locationStr = loc;
    }

    // Fallback for RoboStem-style location fields
    if (locationStr == null || locationStr.isEmpty) {
      final city = json['location_city'] as String?;
      final region = json['location_region'] as String?;
      final country = json['location_country'] as String?;
      locationStr = [city, region, country]
          .where((e) => e != null && e.isNotEmpty)
          .join(', ');
    }

    final statiqRaw = json['statiq'];
    final statiq =
        statiqRaw is Map ? Map<String, dynamic>.from(statiqRaw) : null;

    // Robustly extract TrueSkill (Pure Score)
    num? teamwork;

    // 1. Try properties injected by ApiClient from Pure Endpoint
    if (json['trueskill_data'] is Map) {
      teamwork = json['trueskill_data']['pureScore'] as num?;
    }

    if (statiq != null) {
      // 2. Try statiq['trueskill']['pureScore']
      if (teamwork == null && statiq['trueskill'] is Map) {
        teamwork = statiq['trueskill']['pureScore'] as num?;
      }

      // 3. Try statiq['teamworkQuality'] (Standard Team Details API)
      teamwork ??= statiq['teamworkQuality'] as num?;

      // 4. Fallbacks (Historic/Other endpoints) - raw values, no division
      if (teamwork == null) {
        if (statiq['trueskill'] is Map) {
          teamwork = statiq['trueskill']['score'] as num? ??
              statiq['trueskill']['mu'] as num?;
        }
        teamwork ??= statiq['statiqScore'] as num? ??
            statiq['statiq_score'] as num? ??
            statiq['teamwork'] as num? ??
            statiq['performance'] as num?;
      }
    }

    // Extract skills if they are nested in statiq or at the top level
    Map<String, dynamic>? skills;
    if (statiq != null && statiq['skills'] is Map) {
      skills = Map<String, dynamic>.from(statiq['skills']);
    } else if (json['skills'] is Map) {
      skills = Map<String, dynamic>.from(json['skills']);
    }

    // If we have skills, we might want to inject them into the statiq map for the UI
    if (skills != null && statiq != null) {
      statiq['skills'] = skills;
    }

    // Robust ID parsing:
    // 1. Try 'teamId' (integer)
    // 2. Try 'id' if it's an integer
    // 3. If 'id' is a string, hash it or return 0
    int teamId = 0;
    if (json['teamId'] is int) {
      teamId = json['teamId'] as int;
    } else if (json['id'] is int) {
      teamId = json['id'] as int;
    } else if (json['id'] != null) {
      // Fallback for string ID: Try parse, else hash or 0
      final idStr = json['id'].toString();
      teamId = int.tryParse(idStr) ?? idStr.hashCode;
    }

    String name = json['team_name'] as String? ??
        json['name'] as String? ??
        json['teamName'] as String? ??
        '';
    if (name.isEmpty && json['team'] is Map) {
      final t = json['team'] as Map;
      name = t['team_name'] as String? ??
          t['name'] as String? ??
          t['teamName'] as String? ??
          '';
    }

    return Team(
      id: teamId,
      number: json['number'] as String? ??
          (json['team'] is Map ? json['team']['number'] as String? : null) ??
          '',
      name: name,
      school: json['organization'] as String?,
      organization: json['organization'] as String?,
      robotName: json['robot_name'] as String?,
      worldRank: json['rank'] as int? ??
          json['worldRank'] as int? ??
          json['globalRank'] as int?,
      eventId: 0,
      location: locationStr,
      trueskill: teamwork?.toDouble(),
      statiq: statiq,
      grade: json['grade'] as String? ??
          json['gradeLevel'] as String? ??
          json['grade_level'] as String?,
    );
  }

  Team copyWith({
    int? id,
    String? number,
    String? name,
    String? school,
    String? robotName,
    int? worldRank,
    int? eventId,
    String? organization,
    String? location,
    double? trueskill,
    double? ccwm,
    Map? statiq,
    String? grade,
  }) {
    return Team(
      id: id ?? this.id,
      number: number ?? this.number,
      name: name ?? this.name,
      school: school ?? this.school,
      robotName: robotName ?? this.robotName,
      worldRank: worldRank ?? this.worldRank,
      eventId: eventId ?? this.eventId,
      organization: organization ?? this.organization,
      location: location ?? this.location,
      trueskill: trueskill ?? this.trueskill,
      ccwm: ccwm ?? this.ccwm,
      statiq: statiq ?? this.statiq,
      grade: grade ?? this.grade,
    );
  }

  Map<String, dynamic> toJson() => _$TeamToJson(this);
}
