// [Domain] - 마감 임박 과제 조회 유즈케이스
import '../entities/task.dart';

class GetUpcomingTasks {
  // 오늘부터 N일 이내 미완료 과제 반환 (마감일 오름차순)
  List<Task> call(List<Task> tasks, {int withinDays = 3}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final limit = today.add(Duration(days: withinDays));

    return tasks
        .where((task) {
          if (task.isDone) return false; // 완료된 과제 제외
          final deadline = DateTime(
            task.deadline.year,
            task.deadline.month,
            task.deadline.day,
          );
          // 오늘 이후 ~ N일 이내 마감
          return !deadline.isBefore(today) && !deadline.isAfter(limit);
        })
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline)); // 마감일 오름차순
  }
}
