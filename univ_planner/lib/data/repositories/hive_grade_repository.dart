// [Data] - 성적 Hive 저장소
import 'package:hive/hive.dart';
import '../../domain/entities/grade.dart';

class HiveGradeRepository {
  static const String _boxName = 'grades';

  Future<Box<Grade>> get _box async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<Grade>(_boxName);
    }
    return Hive.box<Grade>(_boxName);
  }

  Future<void> add(Grade grade) async {
    final box = await _box;
    await box.put(grade.id, grade);
  }

  Future<void> delete(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  Future<List<Grade>> getAll() async {
    final box = await _box;
    return box.values.toList();
  }

  Future<Grade?> getById(String id) async {
    final box = await _box;
    return box.get(id);
  }

  // 학기별 성적 조회
  Future<List<Grade>> getBySemester(String semester) async {
    final box = await _box;
    return box.values.where((g) => g.semester == semester).toList();
  }
}
