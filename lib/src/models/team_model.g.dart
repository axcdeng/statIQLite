// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TeamAdapter extends TypeAdapter<Team> {
  @override
  final int typeId = 1;

  @override
  Team read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Team(
      id: fields[0] as int,
      number: fields[1] as String,
      name: fields[2] as String,
      school: fields[3] as String?,
      robotName: fields[4] as String?,
      worldRank: fields[5] as int?,
      eventId: fields[6] as int,
      organization: fields[7] as String?,
      location: fields[8] as String?,
      trueskill: fields[9] as double?,
      ccwm: fields[10] as double?,
      statiq: (fields[11] as Map?)?.cast<String, dynamic>(),
      grade: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Team obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.number)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.school)
      ..writeByte(4)
      ..write(obj.robotName)
      ..writeByte(5)
      ..write(obj.worldRank)
      ..writeByte(6)
      ..write(obj.eventId)
      ..writeByte(7)
      ..write(obj.organization)
      ..writeByte(8)
      ..write(obj.location)
      ..writeByte(9)
      ..write(obj.trueskill)
      ..writeByte(10)
      ..write(obj.ccwm)
      ..writeByte(11)
      ..write(obj.statiq)
      ..writeByte(12)
      ..write(obj.grade);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeamAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$TeamToJson(Team instance) => <String, dynamic>{
      'id': instance.id,
      'number': instance.number,
      'name': instance.name,
      'school': instance.school,
      'robotName': instance.robotName,
      'worldRank': instance.worldRank,
      'eventId': instance.eventId,
      'organization': instance.organization,
      'location': instance.location,
      'trueskill': instance.trueskill,
      'ccwm': instance.ccwm,
      'statiq': instance.statiq,
      'grade': instance.grade,
    };
