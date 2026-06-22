// [Application] - 학점 상태 관리 ViewModel
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/hive_grade_repository.dart';
import '../domain/entities/grade.dart';
import '../domain/usecases/calculate_gpa.dart';

final gradeViewModelProvider =
    StateNotifierProvider<GradeViewModel, List<Grade>>((ref) {
  return GradeViewModel();
});

class GradeViewModel extends StateNotifier<List<Grade>> {
  GradeViewModel() : super([]) {
    load();
  }

  final _repo = HiveGradeRepository();
  final _calculateGpa = CalculateGpa();

  Future<void> load() async {
    state = await _repo.getAll();
  }

  Future<void> add(Grade grade) async {
    await _repo.add(grade);
    await load();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    await load();
  }

  // 전체 GPA 계산
  GpaResult get totalGpa => _calculateGpa(state);

  // 특정 학기 GPA 계산
  GpaResult gpaForSemester(String semester) {
    final filtered = state.where((g) => g.semester == semester).toList();
    return _calculateGpa(filtered);
  }

  // 등록된 학기 목록 (중복 제거, 최신 순)
  List<String> get semesters {
    final set = state.map((g) => g.semester).toSet().toList();
    set.sort((a, b) => b.compareTo(a));
    return set;
  }
}
