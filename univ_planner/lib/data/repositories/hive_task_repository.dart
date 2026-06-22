// [Data] - 과제 Hive 저장소
import 'package:hive/hive.dart';
import '../../domain/entities/task.dart';

class HiveTaskRepository {
  static const String _boxName = 'tasks';

  Future<Box<Task>> get _box async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<Task>(_boxName);
    }
    return Hive.box<Task>(_boxName);
  }

  Future<void> add(Task task) async {
    final box = await _box;
    await box.put(task.id, task);
  }

  Future<void> delete(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  Future<List<Task>> getAll() async {
    final box = await _box;
    return box.values.toList();
  }

  Future<Task?> getById(String id) async {
    final box = await _box;
    return box.get(id);
  }

  Future<void> update(Task task) async {
    final box = await _box;
    await box.put(task.id, task);
  }
}
