// [Domain] - GPA 계산 유즈케이스
import '../entities/grade.dart';

// GPA 계산 결과
class GpaResult {
  final double gpa; // 평점
  final int totalCredits; // 총 이수 학점
  final int courseCount; // 과목 수

  const GpaResult({
    required this.gpa,
    required this.totalCredits,
    required this.courseCount,
  });
}

class CalculateGpa {
  // 가중 평균 방식으로 GPA 계산
  GpaResult call(List<Grade> grades) {
    if (grades.isEmpty) {
      return const GpaResult(gpa: 0.0, totalCredits: 0, courseCount: 0);
    }

    int totalCredits = 0;
    double weightedSum = 0.0;

    for (final grade in grades) {
      if (grade.credit <= 0) continue; // 학점 0 이하 제외 (division by zero 방지)
      totalCredits += grade.credit;
      weightedSum += grade.letter.point * grade.credit;
    }

    final gpa = totalCredits > 0 ? weightedSum / totalCredits : 0.0;

    return GpaResult(
      gpa: double.parse(gpa.toStringAsFixed(2)),
      totalCredits: totalCredits,
      courseCount: grades.length,
    );
  }
}
