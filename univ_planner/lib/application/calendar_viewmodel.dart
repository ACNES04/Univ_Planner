// [Application] - 학사일정 상태 관리 ViewModel
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/hive_schedule_repository.dart';
import '../domain/entities/academic_schedule.dart';

final calendarViewModelProvider =
    StateNotifierProvider<CalendarViewModel, List<AcademicSchedule>>((ref) {
  return CalendarViewModel();
});

class CalendarViewModel extends StateNotifier<List<AcademicSchedule>> {
  CalendarViewModel() : super([]) {
    load();
  }

  final _repo = HiveScheduleRepository();

  Future<void> load() async {
    final all = await _repo.getAll();
    all.sort((a, b) => a.date.compareTo(b.date));
    state = all;
  }

  Future<void> add(AcademicSchedule schedule) async {
    await _repo.add(schedule);
    await load();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    await load();
  }

  Future<void> update(AcademicSchedule schedule) async {
    await _repo.update(schedule);
    await load();
  }

  // 특정 날짜의 일정 목록
  List<AcademicSchedule> schedulesForDay(DateTime day) {
    return state.where((s) {
      return s.date.year == day.year &&
          s.date.month == day.month &&
          s.date.day == day.day;
    }).toList();
  }

  // 이번 주 일정
  List<AcademicSchedule> get thisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    return state.where((s) {
      final d = s.date;
      return !d.isBefore(DateTime(weekStart.year, weekStart.month, weekStart.day)) &&
          !d.isAfter(DateTime(weekEnd.year, weekEnd.month, weekEnd.day, 23, 59));
    }).toList();
  }
}
