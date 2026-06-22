// [Domain] - 과제 엔티티
import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title; // 과제 제목

  @HiveField(2)
  late String? courseId; // 연결 과목 ID (선택)

  @HiveField(3)
  late DateTime deadline; // 마감 일시

  @HiveField(4)
  late String memo; // 메모 (기본 '')

  @HiveField(5)
  late int priority; // 우선순위 (0=낮음, 1=보통, 2=높음)

  @HiveField(6)
  late bool isDone; // 완료 여부

  Task({
    required this.id,
    required this.title,
    this.courseId,
    required this.deadline,
    this.memo = '',
    this.priority = 1,
    this.isDone = false,
  });
}
