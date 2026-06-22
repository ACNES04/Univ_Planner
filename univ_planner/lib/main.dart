// [Presentation] - 앱 진입점, Hive 초기화 및 ProviderScope 설정
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'domain/entities/course.dart';
import 'domain/entities/task.dart';
import 'domain/entities/academic_schedule.dart';
import 'domain/entities/attendance.dart';
import 'domain/entities/grade.dart';
import 'presentation/home/home_screen.dart';
import 'presentation/timetable/timetable_screen.dart';
import 'presentation/calendar/calendar_screen.dart';
import 'presentation/attendance/attendance_screen.dart';
import 'presentation/grade/grade_screen.dart';
import 'presentation/task/task_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 한국어 로케일 초기화 (DateFormat 사용 전 필수)
  await initializeDateFormatting('ko', null);

  // Hive 초기화 + 어댑터 등록
  await Hive.initFlutter();
  Hive.registerAdapter(CourseAdapter());
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(AcademicScheduleAdapter());
  Hive.registerAdapter(AttendanceStatusAdapter());
  Hive.registerAdapter(AttendanceAdapter());
  Hive.registerAdapter(GradeLetterAdapter());
  Hive.registerAdapter(GradeAdapter());

  runApp(
    const ProviderScope(
      child: UnivPlannerApp(),
    ),
  );
}

class UnivPlannerApp extends StatelessWidget {
  const UnivPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Univ Planner',
      debugShowCheckedModeBanner: false,
      // 시스템 다크모드 따라가기
      themeMode: ThemeMode.system,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const MainNavigation(),
    );
  }
}

// 메인 하단 내비게이션 (6개 탭)
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  // 각 탭에 해당하는 화면 목록
  static const List<Widget> _screens = [
    HomeScreen(),
    TimetableScreen(),
    CalendarScreen(),
    AttendanceScreen(),
    GradeScreen(),
    TaskScreen(),
  ];

  // 탭 항목 정의
  static const List<NavigationDestination> _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: '홈',
    ),
    NavigationDestination(
      icon: Icon(Icons.table_chart_outlined),
      selectedIcon: Icon(Icons.table_chart),
      label: '시간표',
    ),
    NavigationDestination(
      icon: Icon(Icons.calendar_month_outlined),
      selectedIcon: Icon(Icons.calendar_month),
      label: '학사일정',
    ),
    NavigationDestination(
      icon: Icon(Icons.how_to_reg_outlined),
      selectedIcon: Icon(Icons.how_to_reg),
      label: '출결',
    ),
    NavigationDestination(
      icon: Icon(Icons.school_outlined),
      selectedIcon: Icon(Icons.school),
      label: '학점',
    ),
    NavigationDestination(
      icon: Icon(Icons.assignment_outlined),
      selectedIcon: Icon(Icons.assignment),
      label: '과제',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: _destinations,
      ),
    );
  }
}
