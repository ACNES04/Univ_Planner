// [Data] - 출결 기록 Hive 저장소
import 'package:hive/hive.dart';
import '../../domain/entities/attendance.dart';

class HiveAttendanceRepository {
  static const String _boxName = 'attendance';

  Future<Box<Attendance>> get _box async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<Attendance>(_boxName);
    }
    return Hive.box<Attendance>(_boxName);
  }

  Future<void> add(Attendance record) async {
    final box = await _box;
    await box.put(record.id, record);
  }

  Future<void> delete(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  Future<List<Attendance>> getAll() async {
    final box = await _box;
    return box.values.toList();
  }

  Future<Attendance?> getById(String id) async {
    final box = await _box;
    return box.get(id);
  }

  // 특정 과목의 출결 기록 조회
  Future<List<Attendance>> getByCourse(String courseId) async {
    final box = await _box;
    return box.values.where((r) => r.courseId == courseId).toList();
  }
}
