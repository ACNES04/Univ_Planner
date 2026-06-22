// [Application] - 출결 상태 관리 ViewModel
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/hive_attendance_repository.dart';
import '../domain/entities/attendance.dart';
import '../domain/usecases/calculate_attendance_limit.dart';

final attendanceViewModelProvider =
    StateNotifierProvider<AttendanceViewModel, List<Attendance>>((ref) {
  return AttendanceViewModel();
});

class AttendanceViewModel extends StateNotifier<List<Attendance>> {
  AttendanceViewModel() : super([]) {
    load();
  }

  final _repo = HiveAttendanceRepository();
  final _calculator = CalculateAttendanceLimit();

  // 학기 총 수업 횟수 (기본 15주)
  int totalClasses = 15;

  Future<void> load() async {
    state = await _repo.getAll();
  }

  Future<void> add(Attendance record) async {
    await _repo.add(record);
    await load();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    await load();
  }

  // 특정 과목의 출결 기록
  List<Attendance> recordsByCourse(String courseId) {
    return state.where((r) => r.courseId == courseId).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // 특정 과목의 출결 한도 계산
  AttendanceLimitResult calculate(String courseId) {
    return _calculator(
      totalClasses: totalClasses,
      records: recordsByCourse(courseId),
    );
  }
}
