// [Domain] - 과목(시간표) 엔티티
import 'package:hive/hive.dart';

part 'course.g.dart';

@HiveType(typeId: 0)
class Course extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name; // 과목명

  @HiveField(2)
  late String professor; // 교수명

  @HiveField(3)
  late int credit; // 학점 (기본 3)

  @HiveField(4)
  late int dayOfWeek; // 요일 (1=월 ~ 5=금)

  @HiveField(5)
  late int startHour; // 시작 시각 (시)

  @HiveField(6)
  late int endHour; // 종료 시각 (시)

  @HiveField(7)
  late String location; // 강의실

  @HiveField(8)
  late int colorValue; // 색상 ARGB (기본 0xFF4F46E5)

  Course({
    required this.id,
    required this.name,
    required this.professor,
    this.credit = 3,
    required this.dayOfWeek,
    required this.startHour,
    required this.endHour,
    this.location = '',
    this.colorValue = 0xFF4F46E5,
  });
}
