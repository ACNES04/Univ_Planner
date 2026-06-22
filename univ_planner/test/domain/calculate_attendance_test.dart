// [Test/Domain] - 출결 한도 계산 유즈케이스 단위 테스트
import 'package:flutter_test/flutter_test.dart';
import 'package:univ_planner/domain/entities/attendance.dart';
import 'package:univ_planner/domain/usecases/calculate_attendance_limit.dart';

void main() {
  final usecase = CalculateAttendanceLimit();

  // 테스트용 Attendance 생성 헬퍼
  Attendance makeRecord(AttendanceStatus status) {
    return Attendance(
      id: '${status}_${DateTime.now().millisecondsSinceEpoch}',
      courseId: 'test_course',
      date: DateTime.now(),
      status: status,
    );
  }

  group('CalculateAttendanceLimit', () {
    test('결석 0회 → safe', () {
      final result = usecase(totalClasses: 15, records: []);
      expect(result.warningLevel, WarningLevel.safe);
      expect(result.absentCount, 0);
      expect(result.absentLimit, 3); // 15 * 0.25 = 3
    });

    test('결석 한도 도달 → danger', () {
      // 한도 = 15 * 0.25 = 3회
      final records = [
        makeRecord(AttendanceStatus.absent),
        makeRecord(AttendanceStatus.absent),
        makeRecord(AttendanceStatus.absent),
      ];
      final result = usecase(totalClasses: 15, records: records);
      expect(result.warningLevel, WarningLevel.danger);
      expect(result.absentCount, 3);
    });

    test('지각 3회 = 결석 1회 환산 검증', () {
      final records = List.generate(3, (_) => makeRecord(AttendanceStatus.late));
      final result = usecase(totalClasses: 15, records: records);
      // 지각 3회 → 결석 1회 환산
      expect(result.absentCount, 1);
      expect(result.lateCount, 3);
    });

    test('지각 2회는 결석 0회 환산 (3회 미만)', () {
      final records = List.generate(2, (_) => makeRecord(AttendanceStatus.late));
      final result = usecase(totalClasses: 15, records: records);
      expect(result.absentCount, 0); // 2 ~/ 3 = 0
      expect(result.lateCount, 2);
    });

    test('caution 경계값: 한도의 75% 이상이면 caution', () {
      // 한도 = 20 * 0.25 = 5회, 75% = 3.75 → ceil = 4회
      final records = List.generate(4, (_) => makeRecord(AttendanceStatus.absent));
      final result = usecase(totalClasses: 20, records: records);
      expect(result.absentLimit, 5);
      expect(result.absentCount, 4);
      expect(result.warningLevel, WarningLevel.caution);
    });

    test('결석 + 지각 혼합 계산', () {
      // 결석 1회 + 지각 6회 → 결석 1 + 6~3 = 결석 3회
      final records = [
        makeRecord(AttendanceStatus.absent),
        ...List.generate(6, (_) => makeRecord(AttendanceStatus.late)),
      ];
      final result = usecase(totalClasses: 15, records: records);
      expect(result.absentCount, 1 + 2); // 결석1 + 지각6~3=2
      expect(result.lateCount, 6);
    });
  });
}
