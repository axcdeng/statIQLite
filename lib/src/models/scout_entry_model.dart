import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'scout_entry_model.freezed.dart';
part 'scout_entry_model.g.dart';

@freezed
class ScoutEntry with _$ScoutEntry {
  @HiveType(typeId: 3, adapterName: 'ScoutEntryAdapter')
  const factory ScoutEntry({
    @HiveField(0) required String id, // UUID
    @HiveField(1) required int eventId,
    @HiveField(2) required int matchId,
    @HiveField(3) required String teamNumber,
    @HiveField(4) required DateTime timestamp,
    @HiveField(5) required Map<String, dynamic> data, // Flexible form data
    @HiveField(6) String? notes,
    @HiveField(7) required String scoutName,
  }) = _ScoutEntry;

  factory ScoutEntry.fromJson(Map<String, dynamic> json) => _$ScoutEntryFromJson(json);
}
