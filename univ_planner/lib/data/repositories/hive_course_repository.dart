// [Data] - 과목 Hive 저장소
import 'package:hive/hive.dart';
import '../../domain/entities/course.dart';

class HiveCourseRepository {
  static const String _boxName = 'courses';

  // Box를 lazy하게 가져옴 (openBox는 main에서 또는 첫 접근 시)
  Future<Box<Course>> get _box async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<Course>(_boxName);
    }
    return Hive.box<Course>(_boxName);
  }

  // 과목 추가
  Future<void> add(Course course) async {
    final box = await _box;
    await box.put(course.id, course);
  }

  // 과목 삭제
  Future<void> delete(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  // 전체 과목 조회
  Future<List<Course>> getAll() async {
    final box = await _box;
    return box.values.toList();
  }

  // ID로 과목 조회
  Future<Course?> getById(String id) async {
    final box = await _box;
    return box.get(id);
  }

  // 과목 수정
  Future<void> update(Course course) async {
    final box = await _box;
    await box.put(course.id, course);
  }
}
