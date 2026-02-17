import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:roboscout_iq/src/models/division.dart';

part 'event_model.g.dart';

@HiveType(typeId: 0, adapterName: 'EventAdapter')
@JsonSerializable(createFactory: false)
class Event {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String? venue;
  @HiveField(3)
  final DateTime startDate;
  @HiveField(4)
  final DateTime endDate;
  @HiveField(5)
  @JsonKey(defaultValue: 'VIQC')
  final String programCode;
  @HiveField(6)
  final DateTime? lastUpdated;
  @HiveField(7)
  final String? location;
  @HiveField(8)
  final String? sku;
  @HiveField(9)
  final String? country;
  @HiveField(10)
  final String? region;
  @HiveField(11)
  final String? level;
  @HiveField(12)
  final List<String>? grades;
  @HiveField(13)
  final List<Division>? divisions;
  @HiveField(14)
  final String? city;
  @HiveField(15)
  final String? seasonName;

  Event({
    required this.id,
    required this.name,
    this.venue,
    required this.startDate,
    required this.endDate,
    this.programCode = 'VIQC',
    this.lastUpdated,
    this.location,
    this.sku,
    this.country,
    this.region,
    this.level,
    this.grades,
    this.divisions,
    this.city,
    this.seasonName,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    // Handle nested objects from RoboStem
    final locationObj = json['location'] as Map<String, dynamic>?;
    final venue = locationObj?['venue'] as String?;
    final city = locationObj?['city'] as String?;
    final region = locationObj?['region'] as String?;
    final country = locationObj?['country'] as String?;
    final location = [city, region, country]
        .where((e) => e != null && e.isNotEmpty)
        .join(', ');

    return Event(
      id: int.parse(json['id'].toString()),
      name: json['name'] as String,
      venue: venue,
      startDate: DateTime.parse(json['start'] as String),
      endDate: DateTime.parse(json['end'] as String),
      programCode:
          (json['program'] as Map<String, dynamic>?)?['code'] as String? ??
              'VIQC',
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
      location: location,
      sku: json['sku'] as String?,
      country: country,
      region: region,
      level: json['level'] as String?,
      grades: (json['grades'] as List?)?.cast<String>(),
      divisions: (json['divisions'] as List?)
          ?.map((e) => Division.fromJson(e as Map<String, dynamic>))
          .toList(),
      city: city,
      seasonName: (json['season'] as Map<String, dynamic>?)?['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => _$EventToJson(this);
}
