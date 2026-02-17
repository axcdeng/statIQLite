// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: library_private_types_in_public_api

part of 'scout_entry_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScoutEntryAdapter extends TypeAdapter<_$ScoutEntryImplImpl> {
  @override
  final int typeId = 3;

  @override
  _$ScoutEntryImplImpl read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return _$ScoutEntryImplImpl(
      id: fields[0] as String,
      eventId: fields[1] as int,
      matchId: fields[2] as int,
      teamNumber: fields[3] as String,
      timestamp: fields[4] as DateTime,
      data: (fields[5] as Map).cast<String, dynamic>(),
      notes: fields[6] as String?,
      scoutName: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, _$ScoutEntryImplImpl obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.eventId)
      ..writeByte(2)
      ..write(obj.matchId)
      ..writeByte(3)
      ..write(obj.teamNumber)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.scoutName)
      ..writeByte(5)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoutEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScoutEntryImplImpl _$$ScoutEntryImplImplFromJson(Map<String, dynamic> json) =>
    _$ScoutEntryImplImpl(
      id: json['id'] as String,
      eventId: (json['eventId'] as num).toInt(),
      matchId: (json['matchId'] as num).toInt(),
      teamNumber: json['teamNumber'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      data: json['data'] as Map<String, dynamic>,
      notes: json['notes'] as String?,
      scoutName: json['scoutName'] as String,
    );

Map<String, dynamic> _$$ScoutEntryImplImplToJson(
        _$ScoutEntryImplImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventId': instance.eventId,
      'matchId': instance.matchId,
      'teamNumber': instance.teamNumber,
      'timestamp': instance.timestamp.toIso8601String(),
      'data': instance.data,
      'notes': instance.notes,
      'scoutName': instance.scoutName,
    };
