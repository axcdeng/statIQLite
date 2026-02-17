// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventAdapter extends TypeAdapter<Event> {
  @override
  final int typeId = 0;

  @override
  Event read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Event(
      id: fields[0] as int,
      name: fields[1] as String,
      venue: fields[2] as String?,
      startDate: fields[3] as DateTime,
      endDate: fields[4] as DateTime,
      programCode: fields[5] as String,
      lastUpdated: fields[6] as DateTime?,
      location: fields[7] as String?,
      sku: fields[8] as String?,
      country: fields[9] as String?,
      region: fields[10] as String?,
      level: fields[11] as String?,
      grades: (fields[12] as List?)?.cast<String>(),
      divisions: (fields[13] as List?)?.cast<Division>(),
      city: fields[14] as String?,
      seasonName: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Event obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.venue)
      ..writeByte(3)
      ..write(obj.startDate)
      ..writeByte(4)
      ..write(obj.endDate)
      ..writeByte(5)
      ..write(obj.programCode)
      ..writeByte(6)
      ..write(obj.lastUpdated)
      ..writeByte(7)
      ..write(obj.location)
      ..writeByte(8)
      ..write(obj.sku)
      ..writeByte(9)
      ..write(obj.country)
      ..writeByte(10)
      ..write(obj.region)
      ..writeByte(11)
      ..write(obj.level)
      ..writeByte(12)
      ..write(obj.grades)
      ..writeByte(13)
      ..write(obj.divisions)
      ..writeByte(14)
      ..write(obj.city)
      ..writeByte(15)
      ..write(obj.seasonName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Map<String, dynamic> _$EventToJson(Event instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'venue': instance.venue,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'programCode': instance.programCode,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
      'location': instance.location,
      'sku': instance.sku,
      'country': instance.country,
      'region': instance.region,
      'level': instance.level,
      'grades': instance.grades,
      'divisions': instance.divisions,
      'city': instance.city,
      'seasonName': instance.seasonName,
    };
