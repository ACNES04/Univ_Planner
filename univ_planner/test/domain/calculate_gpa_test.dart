// [Test/Domain] - GPA 계산 유즈케이스 단위 테스트
import 'package:flutter_test/flutter_test.dart';
import 'package:univ_planner/domain/entities/grade.dart';
import 'package:univ_planner/domain/usecases/calculate_gpa.dart';

void main() {
  final usecase = CalculateGpa();

  // 테스트용 Grade 생성 헬퍼
  Grade makeGrade(String courseName, int credit, GradeLetter letter) {
    return Grade(
      id: courseName,
      courseName: courseName,
      credit: credit,
      letter: letter,
      semester: '2025-1',
    );
  }

  group('CalculateGpa', () {
    test('빈 목록이면 GPA 0.0 반환', () {
      final result = usecase([]);
      expect(result.gpa, 0.0);
      expect(result.totalCredits, 0);
      expect(result.courseCount, 0);
    });

    test('단일 과목 A+ 3학점 → GPA 4.5', () {
      final result = usecase([makeGrade('과목A', 3, GradeLetter.aPlus)]);
      expect(result.gpa, 4.5);
      expect(result.totalCredits, 3);
      expect(result.courseCount, 1);
    });

    test('복수 과목 가중 평균 정확성: A+(3학점) + B(3학점) → GPA 3.75', () {
      final grades = [
        makeGrade('과목A', 3, GradeLetter.aPlus), // 4.5 * 3 = 13.5
        makeGrade('과목B', 3, GradeLetter.b), // 3.0 * 3 = 9.0
        // 합계: 22.5 / 6 = 3.75
      ];
      final result = usecase(grades);
      expect(result.gpa, 3.75);
      expect(result.totalCredits, 6);
    });

    test('학점 0인 과목은 GPA 계산에서 제외 (division by zero 방지)', () {
      final grades = [
        makeGrade('정상과목', 3, GradeLetter.a),
        makeGrade('학점0과목', 0, GradeLetter.aPlus), // 제외되어야 함
      ];
      final result = usecase(grades);
      expect(result.gpa, 4.0);
      expect(result.totalCredits, 3);
    });

    test('F 등급은 0.0점으로 처리', () {
      final result = usecase([makeGrade('낙제', 3, GradeLetter.f)]);
      expect(result.gpa, 0.0);
    });

    test('여러 과목 학점 가중 평균 정확성', () {
      final grades = [
        makeGrade('과목A', 2, GradeLetter.aPlus), // 4.5 * 2 = 9.0
        makeGrade('과목B', 3, GradeLetter.b), // 3.0 * 3 = 9.0
        makeGrade('과목C', 1, GradeLetter.c), // 2.0 * 1 = 2.0
        // 합계: 20.0 / 6 ≈ 3.33
      ];
      final result = usecase(grades);
      expect(result.totalCredits, 6);
      expect(result.gpa, closeTo(3.33, 0.01));
    });
  });
}
