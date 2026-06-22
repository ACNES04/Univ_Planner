// [Data] - 학사일정 Hive 저장소
import 'package:hive/hive.dart';
import '../../domain/entities/academic_schedule.dart';

class HiveScheduleRepository {
  static const String _boxName = 'schedules';

  Future<Box<AcademicSchedule>> get _box async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<AcademicSchedule>(_boxName);
    }
    return Hive.box<AcademicSchedule>(_boxName);
  }

  Future<void> add(AcademicSchedule schedule) async {
    final box = await _box;
    await box.put(schedule.id, schedule);
  }

  Future<void> delete(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  Future<List<AcademicSchedule>> getAll() async {
    final box = await _box;
    return box.values.toList();
  }

  Future<AcademicSchedule?> getById(String id) async {
    final box = await _box;
    return box.get(id);
  }

  Future<void> update(AcademicSchedule schedule) async {
    final box = await _box;
    await box.put(schedule.id, schedule);
  }
}
