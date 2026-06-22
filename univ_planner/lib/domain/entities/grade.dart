// [Domain] - 성적 엔티티 + 등급 열거형
import 'package:hive/hive.dart';

part 'grade.g.dart';

// 성적 등급 열거형
@HiveType(typeId: 11)
enum GradeLetter {
  @HiveField(0)
  aPlus,

  @HiveField(1)
  a,

  @HiveField(2)
  bPlus,

  @HiveField(3)
  b,

  @HiveField(4)
  cPlus,

  @HiveField(5)
  c,

  @HiveField(6)
  dPlus,

  @HiveField(7)
  d,

  @HiveField(8)
  f,
}

// GradeLetter 확장: 환산점수와 표시 레이블
extension GradeLetterExt on GradeLetter {
  double get point {
    switch (this) {
      case GradeLetter.aPlus:
        return 4.5;
      case GradeLetter.a:
        return 4.0;
      case GradeLetter.bPlus:
        return 3.5;
      case GradeLetter.b:
        return 3.0;
      case GradeLetter.cPlus:
        return 2.5;
      case GradeLetter.c:
        return 2.0;
      case GradeLetter.dPlus:
        return 1.5;
      case GradeLetter.d:
        return 1.0;
      case GradeLetter.f:
        return 0.0;
    }
  }

  String get label {
    switch (this) {
      case GradeLetter.aPlus:
        return 'A+';
      case GradeLetter.a:
        return 'A';
      case GradeLetter.bPlus:
        return 'B+';
      case GradeLetter.b:
        return 'B';
      case GradeLetter.cPlus:
        return 'C+';
      case GradeLetter.c:
        return 'C';
      case GradeLetter.dPlus:
        return 'D+';
      case GradeLetter.d:
        return 'D';
      case GradeLetter.f:
        return 'F';
    }
  }
}

@HiveType(typeId: 4)
class Grade extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String courseName; // 과목명

  @HiveField(2)
  late int credit; // 학점

  @HiveField(3)
  late GradeLetter letter; // 등급

  @HiveField(4)
  late String semester; // 학기 (예: "2025-1")

  Grade({
    required this.id,
    required this.courseName,
    required this.credit,
    required this.letter,
    required this.semester,
  });
}
