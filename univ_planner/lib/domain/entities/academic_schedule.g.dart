// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'academic_schedule.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AcademicScheduleAdapter extends TypeAdapter<AcademicSchedule> {
  @override
  final int typeId = 2;

  @override
  AcademicSchedule read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AcademicSchedule(
      id: fields[0] as String,
      title: fields[1] as String,
      date: fields[2] as DateTime,
      memo: fields[3] as String,
      category: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AcademicSchedule obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.memo)
      ..writeByte(4)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AcademicScheduleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
