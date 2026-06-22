// [Core] - 앱 전체에서 사용하는 색상 상수 정의
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // 인디고 팔레트
  static const Color indigo50 = Color(0xFFEEF2FF);
  static const Color indigo100 = Color(0xFFE0E7FF);
  static const Color indigo200 = Color(0xFFC7D2FE);
  static const Color indigo300 = Color(0xFFA5B4FC);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo600 = Color(0xFF4F46E5);
  static const Color indigo700 = Color(0xFF4338CA);
  static const Color indigo800 = Color(0xFF3730A3);
  static const Color indigo900 = Color(0xFF312E81);

  // 상태 색상
  static const Color success = Color(0xFF16A34A); // green.600
  static const Color warning = Color(0xFFD97706); // amber.600
  static const Color danger = Color(0xFFDC2626); // red.600

  // 출결 색상
  static const Color present = Color(0xFF16A34A); // 출석 - 초록
  static const Color late = Color(0xFFD97706); // 지각 - 주황
  static const Color absent = Color(0xFFDC2626); // 결석 - 빨강

  // 과목 카드 색상 6가지
  static const List<Color> courseColors = [
    Color(0xFF4F46E5), // 인디고
    Color(0xFF7C3AED), // 보라
    Color(0xFFDB2777), // 핑크
    Color(0xFF059669), // 에메랄드
    Color(0xFFD97706), // 앰버
    Color(0xFF0284C7), // 스카이블루
  ];

  // 학점 등급 색상 맵
  static const Map<String, Color> gradeColors = {
    'A+': Color(0xFF4F46E5),
    'A': Color(0xFF0284C7),
    'B+': Color(0xFF059669),
    'B': Color(0xFF16A34A),
    'C+': Color(0xFFD97706),
    'C': Color(0xFFEA580C),
    'D+': Color(0xFFDC2626),
    'D': Color(0xFFB91C1C),
    'F': Color(0xFF6B7280),
  };

  // 학사일정 카테고리 색상
  static const Color categoryAcademic = Color(0xFF0284C7); // 학사 - 파랑
  static const Color categoryExam = Color(0xFFDC2626); // 시험 - 빨강
  static const Color categoryHoliday = Color(0xFF16A34A); // 휴일 - 초록
  static const Color categoryEtc = Color(0xFF6B7280); // 기타 - 회색
}
