// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScoreEntryAdapter extends TypeAdapter<ScoreEntry> {
  @override
  final int typeId = 4;

  @override
  ScoreEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScoreEntry(
      connectedPins: fields[0] as int,
      connectedBeams: fields[1] as int,
      twoColorStacks: fields[2] as int,
      threeColorStacks: fields[3] as int,
      matchingGoalOrBeam: fields[4] as int,
      standoffGoal: fields[5] as int,
      clearedStartingPins: fields[6] as int,
      robotsContacting: fields[7] as int,
      date: fields[8] as DateTime,
      totalScore: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ScoreEntry obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.connectedPins)
      ..writeByte(1)
      ..write(obj.connectedBeams)
      ..writeByte(2)
      ..write(obj.twoColorStacks)
      ..writeByte(3)
      ..write(obj.threeColorStacks)
      ..writeByte(4)
      ..write(obj.matchingGoalOrBeam)
      ..writeByte(5)
      ..write(obj.standoffGoal)
      ..writeByte(6)
      ..write(obj.clearedStartingPins)
      ..writeByte(7)
      ..write(obj.robotsContacting)
      ..writeByte(8)
      ..write(obj.date)
      ..writeByte(9)
      ..write(obj.totalScore);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
