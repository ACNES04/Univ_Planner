// [Application] - 시간표 상태 관리 ViewModel
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/hive_course_repository.dart';
import '../domain/entities/course.dart';

// 시간표 ViewModel Provider
final timetableViewModelProvider =
    StateNotifierProvider<TimetableViewModel, List<Course>>((ref) {
  return TimetableViewModel();
});

class TimetableViewModel extends StateNotifier<List<Course>> {
  TimetableViewModel() : super([]) {
    load();
  }

  final _repo = HiveCourseRepository();

  // 전체 과목 불러오기
  Future<void> load() async {
    state = await _repo.getAll();
  }

  // 과목 추가
  Future<void> add(Course course) async {
    await _repo.add(course);
    await load();
  }

  // 과목 삭제
  Future<void> delete(String id) async {
    await _repo.delete(id);
    await load();
  }

  // 과목 수정
  Future<void> update(Course course) async {
    await _repo.update(course);
    await load();
  }

  // 특정 요일의 과목 목록 (시간 순 정렬)
  List<Course> coursesByDay(int dayOfWeek) {
    return state
        .where((c) => c.dayOfWeek == dayOfWeek)
        .toList()
      ..sort((a, b) => a.startHour.compareTo(b.startHour));
  }

  // 오늘 수업 목록
  List<Course> get todayCourses {
    final weekday = DateTime.now().weekday; // 1=월 ~ 7=일
    if (weekday > 5) return []; // 주말은 수업 없음
    return coursesByDay(weekday);
  }
}
