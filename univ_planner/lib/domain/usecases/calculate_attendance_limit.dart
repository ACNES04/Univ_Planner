// [Domain] - 결석 한도 계산 유즈케이스
import '../entities/attendance.dart';

// 경고 수준
enum WarningLevel {
  safe, // 안전 (75% 미만)
  caution, // 주의 (75% 이상)
  danger, // 위험 (100% 이상)
}

// 출결 한도 계산 결과
class AttendanceLimitResult {
  final int absentCount; // 결석 횟수 (지각 환산 포함)
  final int lateCount; // 지각 횟수
  final int absentLimit; // 결석 허용 한도
  final WarningLevel warningLevel; // 경고 수준

  const AttendanceLimitResult({
    required this.absentCount,
    required this.lateCount,
    required this.absentLimit,
    required this.warningLevel,
  });
}

class CalculateAttendanceLimit {
  // 결석 한도 계산: 지각 3회 = 결석 1회, 한도 = 총 수업 x 0.25
  AttendanceLimitResult call({
    required int totalClasses,
    required List<Attendance> records,
  }) {
    // 지각 횟수 카운트
    final lateCount = records.where((r) => r.status == AttendanceStatus.late).length;

    // 실제 결석 횟수
    final rawAbsentCount = records.where((r) => r.status == AttendanceStatus.absent).length;

    // 지각 3회를 결석 1회로 환산한 총 결석 수
    final absentCount = rawAbsentCount + (lateCount ~/ 3);

    // 결석 허용 한도 (25%)
    final absentLimit = (totalClasses * 0.25).floor();

    // 경고 수준 결정
    final WarningLevel warningLevel;
    if (absentCount >= absentLimit) {
      warningLevel = WarningLevel.danger;
    } else if (absentLimit > 0 && absentCount >= (absentLimit * 0.75).ceil()) {
      warningLevel = WarningLevel.caution;
    } else {
      warningLevel = WarningLevel.safe;
    }

    return AttendanceLimitResult(
      absentCount: absentCount,
      lateCount: lateCount,
      absentLimit: absentLimit,
      warningLevel: warningLevel,
    );
  }
}
