// [Test/Domain] - 마감 임박 과제 조회 유즈케이스 단위 테스트
import 'package:flutter_test/flutter_test.dart';
import 'package:univ_planner/domain/entities/task.dart';
import 'package:univ_planner/domain/usecases/get_upcoming_tasks.dart';

void main() {
  final usecase = GetUpcomingTasks();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  // 테스트용 Task 생성 헬퍼
  Task makeTask(String id, DateTime deadline, {bool isDone = false}) {
    return Task(
      id: id,
      title: '과제_$id',
      deadline: deadline,
      isDone: isDone,
    );
  }

  group('GetUpcomingTasks', () {
    test('마감 지난 과제는 제외', () {
      final tasks = [
        makeTask('past', today.subtract(const Duration(days: 1))), // 어제 마감
        makeTask('today', today), // 오늘 마감
      ];
      final result = usecase(tasks, withinDays: 3);
      expect(result.length, 1);
      expect(result.first.id, 'today');
    });

    test('완료된 과제는 제외', () {
      final tasks = [
        makeTask('done', today.add(const Duration(days: 1)), isDone: true),
        makeTask('pending', today.add(const Duration(days: 1))),
      ];
      final result = usecase(tasks, withinDays: 3);
      expect(result.length, 1);
      expect(result.first.id, 'pending');
    });

    test('마감일 오름차순 정렬 확인', () {
      final tasks = [
        makeTask('day3', today.add(const Duration(days: 3))),
        makeTask('day1', today.add(const Duration(days: 1))),
        makeTask('day2', today.add(const Duration(days: 2))),
      ];
      final result = usecase(tasks, withinDays: 3);
      expect(result.map((t) => t.id).toList(), ['day1', 'day2', 'day3']);
    });

    test('N일 초과 과제는 포함하지 않음', () {
      final tasks = [
        makeTask('within', today.add(const Duration(days: 3))),
        makeTask('beyond', today.add(const Duration(days: 4))), // 4일 뒤는 제외
      ];
      final result = usecase(tasks, withinDays: 3);
      expect(result.length, 1);
      expect(result.first.id, 'within');
    });

    test('빈 목록이면 빈 결과 반환', () {
      final result = usecase([], withinDays: 3);
      expect(result, isEmpty);
    });

    test('withinDays 기본값 3일 동작 확인', () {
      final tasks = [
        makeTask('d2', today.add(const Duration(days: 2))),
        makeTask('d5', today.add(const Duration(days: 5))),
      ];
      final result = usecase(tasks); // 기본 3일
      expect(result.length, 1);
      expect(result.first.id, 'd2');
    });
  });
}
