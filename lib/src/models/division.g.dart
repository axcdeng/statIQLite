// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'division.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DivisionAdapter extends TypeAdapter<Division> {
  @override
  final int typeId = 5;

  @override
  Division read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Division(
      id: fields[0] as int,
      name: fields[1] as String,
      order: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Division obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.order);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DivisionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Division _$DivisionFromJson(Map<String, dynamic> json) => Division(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      order: (json['order'] as num).toInt(),
    );

Map<String, dynamic> _$DivisionToJson(Division instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'order': instance.order,
    };
