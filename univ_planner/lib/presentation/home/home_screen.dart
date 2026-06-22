// [Presentation] - 홈 화면: 오늘 수업, 마감 임박 과제, 이번 주 학사일정
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../application/timetable_viewmodel.dart';
import '../../application/task_viewmodel.dart';
import '../../application/calendar_viewmodel.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/empty_state.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/academic_schedule.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    // watch로 상태 변화 감지 후 notifier에서 파생 데이터 계산
    ref.watch(timetableViewModelProvider);
    ref.watch(taskViewModelProvider);
    ref.watch(calendarViewModelProvider);

    // 오늘 수업
    final todayCourses = ref.read(timetableViewModelProvider.notifier).todayCourses;
    // 마감 임박 과제 (3일 이내)
    final upcomingTasks = ref.read(taskViewModelProvider.notifier).getUpcoming(withinDays: 3);
    // 이번 주 일정
    final weekSchedules = ref.read(calendarViewModelProvider.notifier).thisWeek;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 상단 날짜/요일 헤더
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('M월 d일', 'ko').format(now),
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      DateFormat('EEEE', 'ko').format(now),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 오늘 수업 섹션
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: SectionHeader(
                  icon: Icons.table_chart,
                  title: '오늘 수업',
                ),
              ),
            ),
            if (todayCourses.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: EmptyState(
                    icon: Icons.event_available,
                    title: '오늘 수업이 없습니다',
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: _CourseCard(course: todayCourses[i]),
                  ),
                  childCount: todayCourses.length,
                ),
              ),

            // 마감 임박 과제 섹션
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: SectionHeader(
                  icon: Icons.assignment,
                  title: '마감 임박 과제',
                ),
              ),
            ),
            if (upcomingTasks.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: EmptyState(
                    icon: Icons.task_alt,
                    title: '마감 임박 과제가 없습니다',
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: _TaskCard(task: upcomingTasks[i]),
                  ),
                  childCount: upcomingTasks.length,
                ),
              ),

            // 이번 주 학사일정 섹션
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: SectionHeader(
                  icon: Icons.calendar_month,
                  title: '이번 주 학사일정',
                ),
              ),
            ),
            if (weekSchedules.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: EmptyState(
                    icon: Icons.calendar_today,
                    title: '이번 주 일정이 없습니다',
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: _ScheduleCard(schedule: weekSchedules[i]),
                  ),
                  childCount: weekSchedules.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

// 오늘 수업 카드
class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});
  final Course course;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(course.colorValue);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            // 왼쪽 색상 인디케이터
            Container(width: 4, color: color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${course.professor} 교수',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${course.startHour}:00 ~ ${course.endHour}:00',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          course.location,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 마감 임박 과제 카드
class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});
  final Task task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadline = DateTime(task.deadline.year, task.deadline.month, task.deadline.day);
    final diff = deadline.difference(today).inDays;

    // D-Day 배지 색상
    final badgeColor = diff <= 1 ? AppColors.danger : AppColors.warning;
    final badgeText = diff == 0 ? 'D-Day' : 'D-$diff';

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                task.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badgeText,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: badgeColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 학사일정 카드
class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.schedule});
  final AcademicSchedule schedule;

  static const List<Color> _catColors = [
    AppColors.categoryAcademic,
    AppColors.categoryExam,
    AppColors.categoryHoliday,
    AppColors.categoryEtc,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _catColors[schedule.category.clamp(0, 3)];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Text(
              DateFormat('M/d', 'ko').format(schedule.date),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                schedule.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
