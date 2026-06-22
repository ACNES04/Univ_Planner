// [Domain] - 출결 기록 엔티티 + 출결 상태 열거형
import 'package:hive/hive.dart';

part 'attendance.g.dart';

// 출결 상태 열거형
@HiveType(typeId: 10)
enum AttendanceStatus {
  @HiveField(0)
  present, // 출석

  @HiveField(1)
  late, // 지각

  @HiveField(2)
  absent, // 결석
}

@HiveType(typeId: 3)
class Attendance extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String courseId; // 연결 과목 ID

  @HiveField(2)
  late DateTime date; // 날짜

  @HiveField(3)
  late AttendanceStatus status; // 출결 상태

  Attendance({
    required this.id,
    required this.courseId,
    required this.date,
    required this.status,
  });
}
