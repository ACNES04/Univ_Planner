// [Domain] - 학사일정 엔티티
import 'package:hive/hive.dart';

part 'academic_schedule.g.dart';

@HiveType(typeId: 2)
class AcademicSchedule extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title; // 일정 제목

  @HiveField(2)
  late DateTime date; // 일정 날짜

  @HiveField(3)
  late String memo; // 메모

  @HiveField(4)
  late int category; // 카테고리 (0=학사, 1=시험, 2=휴일, 3=기타)

  AcademicSchedule({
    required this.id,
    required this.title,
    required this.date,
    this.memo = '',
    this.category = 0,
  });
}
