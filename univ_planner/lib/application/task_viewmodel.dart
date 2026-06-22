// [Application] - 과제 상태 관리 ViewModel
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/hive_task_repository.dart';
import '../domain/entities/task.dart';
import '../domain/usecases/get_upcoming_tasks.dart';

final taskViewModelProvider =
    StateNotifierProvider<TaskViewModel, List<Task>>((ref) {
  return TaskViewModel();
});

class TaskViewModel extends StateNotifier<List<Task>> {
  TaskViewModel() : super([]) {
    load();
  }

  final _repo = HiveTaskRepository();
  final _getUpcoming = GetUpcomingTasks();

  Future<void> load() async {
    final all = await _repo.getAll();
    // 마감일 오름차순으로 정렬
    all.sort((a, b) => a.deadline.compareTo(b.deadline));
    state = all;
  }

  Future<void> add(Task task) async {
    await _repo.add(task);
    await load();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    await load();
  }

  Future<void> update(Task task) async {
    await _repo.update(task);
    await load();
  }

  // 완료 여부 토글
  Future<void> toggleDone(String id) async {
    final task = await _repo.getById(id);
    if (task == null) return;
    task.isDone = !task.isDone;
    await _repo.update(task);
    await load();
  }

  // 마감 임박 과제 (N일 이내)
  List<Task> getUpcoming({int withinDays = 3}) {
    return _getUpcoming(state, withinDays: withinDays);
  }

  // 미완료 과제
  List<Task> get pending => state.where((t) => !t.isDone).toList();

  // 완료 과제
  List<Task> get done => state.where((t) => t.isDone).toList();
}
