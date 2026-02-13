// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MatchAdapter extends TypeAdapter<MatchModel> {
  @override
  final int typeId = 2;

  @override
  MatchModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MatchModel(
      id: fields[0] as int,
      eventId: fields[1] as int,
      name: fields[2] as String,
      round: fields[3] as int,
      instance: fields[4] as int,
      matchNum: fields[5] as int,
      redAllianceTeamIds: (fields[6] as List).cast<int>(),
      blueAllianceTeamIds: (fields[7] as List).cast<int>(),
      redAllianceTeamNums: (fields[12] as List).cast<String>(),
      blueAllianceTeamNums: (fields[13] as List).cast<String>(),
      scheduledTime: fields[8] as DateTime?,
      redScore: fields[9] as int?,
      blueScore: fields[10] as int?,
      winner: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MatchModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.eventId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.round)
      ..writeByte(4)
      ..write(obj.instance)
      ..writeByte(5)
      ..write(obj.matchNum)
      ..writeByte(6)
      ..write(obj.redAllianceTeamIds)
      ..writeByte(7)
      ..write(obj.blueAllianceTeamIds)
      ..writeByte(8)
      ..write(obj.scheduledTime)
      ..writeByte(9)
      ..write(obj.redScore)
      ..writeByte(10)
      ..write(obj.blueScore)
      ..writeByte(11)
      ..write(obj.winner)
      ..writeByte(12)
      ..write(obj.redAllianceTeamNums)
      ..writeByte(13)
      ..write(obj.blueAllianceTeamNums);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatchModel _$MatchModelFromJson(Map<String, dynamic> json) => MatchModel(
      id: (json['id'] as num).toInt(),
      eventId: (json['eventId'] as num).toInt(),
      name: json['name'] as String,
      round: (json['round'] as num).toInt(),
      instance: (json['instance'] as num).toInt(),
      matchNum: (json['matchNum'] as num).toInt(),
      redAllianceTeamIds: (json['redAllianceTeamIds'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      blueAllianceTeamIds: (json['blueAllianceTeamIds'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      redAllianceTeamNums: (json['redAllianceTeamNums'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      blueAllianceTeamNums: (json['blueAllianceTeamNums'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      scheduledTime: json['scheduledTime'] == null
          ? null
          : DateTime.parse(json['scheduledTime'] as String),
      redScore: (json['redScore'] as num?)?.toInt(),
      blueScore: (json['blueScore'] as num?)?.toInt(),
      winner: json['winner'] as String?,
    );

Map<String, dynamic> _$MatchModelToJson(MatchModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventId': instance.eventId,
      'name': instance.name,
      'round': instance.round,
      'instance': instance.instance,
      'matchNum': instance.matchNum,
      'redAllianceTeamIds': instance.redAllianceTeamIds,
      'blueAllianceTeamIds': instance.blueAllianceTeamIds,
      'scheduledTime': instance.scheduledTime?.toIso8601String(),
      'redScore': instance.redScore,
      'blueScore': instance.blueScore,
      'winner': instance.winner,
      'redAllianceTeamNums': instance.redAllianceTeamNums,
      'blueAllianceTeamNums': instance.blueAllianceTeamNums,
    };
