// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grade.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GradeAdapter extends TypeAdapter<Grade> {
  @override
  final int typeId = 4;

  @override
  Grade read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Grade(
      id: fields[0] as String,
      courseName: fields[1] as String,
      credit: fields[2] as int,
      letter: fields[3] as GradeLetter,
      semester: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Grade obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.courseName)
      ..writeByte(2)
      ..write(obj.credit)
      ..writeByte(3)
      ..write(obj.letter)
      ..writeByte(4)
      ..write(obj.semester);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GradeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GradeLetterAdapter extends TypeAdapter<GradeLetter> {
  @override
  final int typeId = 11;

  @override
  GradeLetter read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GradeLetter.aPlus;
      case 1:
        return GradeLetter.a;
      case 2:
        return GradeLetter.bPlus;
      case 3:
        return GradeLetter.b;
      case 4:
        return GradeLetter.cPlus;
      case 5:
        return GradeLetter.c;
      case 6:
        return GradeLetter.dPlus;
      case 7:
        return GradeLetter.d;
      case 8:
        return GradeLetter.f;
      default:
        return GradeLetter.aPlus;
    }
  }

  @override
  void write(BinaryWriter writer, GradeLetter obj) {
    switch (obj) {
      case GradeLetter.aPlus:
        writer.writeByte(0);
        break;
      case GradeLetter.a:
        writer.writeByte(1);
        break;
      case GradeLetter.bPlus:
        writer.writeByte(2);
        break;
      case GradeLetter.b:
        writer.writeByte(3);
        break;
      case GradeLetter.cPlus:
        writer.writeByte(4);
        break;
      case GradeLetter.c:
        writer.writeByte(5);
        break;
      case GradeLetter.dPlus:
        writer.writeByte(6);
        break;
      case GradeLetter.d:
        writer.writeByte(7);
        break;
      case GradeLetter.f:
        writer.writeByte(8);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GradeLetterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
