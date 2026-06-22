// [Presentation] - 출결 관리 화면: 과목별 출결 현황 + 기록 추가
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../application/attendance_viewmodel.dart';
import '../../application/timetable_viewmodel.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/entities/course.dart';
import '../../domain/usecases/calculate_attendance_limit.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final courses = ref.watch(timetableViewModelProvider);
    ref.watch(attendanceViewModelProvider);
    final vm = ref.read(attendanceViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('출결 관리'),
        actions: [
          // 총 수업 횟수 설정 버튼
          TextButton.icon(
            onPressed: () => _showTotalClassesDialog(context, vm),
            icon: const Icon(Icons.settings, size: 18),
            label: Text('${vm.totalClasses}회'),
          ),
        ],
      ),
      body: courses.isEmpty
          ? const EmptyState(
              icon: Icons.how_to_reg_outlined,
              title: '등록된 과목이 없습니다',
              description: '시간표 탭에서 과목을 먼저 추가하세요',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: courses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) => _CourseAttendanceCard(course: courses[i]),
            ),
    );
  }

  Future<void> _showTotalClassesDialog(
      BuildContext context, AttendanceViewModel vm) async {
    final ctrl = TextEditingController(text: vm.totalClasses.toString());
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('총 수업 횟수 설정'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '총 수업 횟수',
            suffixText: '회',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(
            onPressed: () {
              final val = int.tryParse(ctrl.text);
              if (val != null && val > 0) {
                vm.totalClasses = val;
                setState(() {});
              }
              Navigator.pop(context);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

// 과목별 출결 카드
class _CourseAttendanceCard extends ConsumerWidget {
  const _CourseAttendanceCard({required this.course});
  final Course course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final vm = ref.read(attendanceViewModelProvider.notifier);
    final result = vm.calculate(course.id);

    // 경고 수준에 따른 색상
    final Color levelColor;
    switch (result.warningLevel) {
      case WarningLevel.safe:
        levelColor = AppColors.success;
      case WarningLevel.caution:
        levelColor = AppColors.warning;
      case WarningLevel.danger:
        levelColor = AppColors.danger;
    }

    final progress = result.absentLimit > 0
        ? (result.absentCount / result.absentLimit).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: () => _showRecordSheet(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Color(course.colorValue),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      course.name,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  // 경고 배지
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: levelColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      result.warningLevel == WarningLevel.safe
                          ? '안전'
                          : result.warningLevel == WarningLevel.caution
                              ? '주의'
                              : '위험',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: levelColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 출결 통계
              Row(
                children: [
                  _StatChip('결석', '${result.absentCount}회', AppColors.absent),
                  const SizedBox(width: 8),
                  _StatChip('지각', '${result.lateCount}회', AppColors.late),
                  const Spacer(),
                  Text(
                    '한도: ${result.absentCount}/${result.absentLimit}회',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 진행 바
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  color: levelColor,
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecordSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AttendanceRecordSheet(course: course),
    );
  }
}

// 통계 칩
class _StatChip extends StatelessWidget {
  const _StatChip(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.labelSmall,
          children: [
            TextSpan(text: '$label ', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
            TextSpan(text: value, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// 출결 기록 BottomSheet
class _AttendanceRecordSheet extends ConsumerStatefulWidget {
  const _AttendanceRecordSheet({required this.course});
  final Course course;

  @override
  ConsumerState<_AttendanceRecordSheet> createState() => _AttendanceRecordSheetState();
}

class _AttendanceRecordSheetState extends ConsumerState<_AttendanceRecordSheet> {
  DateTime _date = DateTime.now();
  AttendanceStatus _status = AttendanceStatus.present;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final records = ref.read(attendanceViewModelProvider.notifier)
        .recordsByCourse(widget.course.id);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (ctx, scrollCtrl) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.course.name,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),

            // 날짜 선택
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(DateFormat('yyyy년 M월 d일', 'ko').format(_date)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const Divider(),

            // 출결 상태 선택
            const SizedBox(height: 8),
            Text('출결 상태', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                _statusButton('출석', AttendanceStatus.present, AppColors.present),
                const SizedBox(width: 8),
                _statusButton('지각', AttendanceStatus.late, AppColors.late),
                const SizedBox(width: 8),
                _statusButton('결석', AttendanceStatus.absent, AppColors.absent),
              ],
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _addRecord,
                child: const Text('기록 추가'),
              ),
            ),
            const SizedBox(height: 16),

            Text('기록 히스토리', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),

            Expanded(
              child: records.isEmpty
                  ? const Center(child: Text('기록이 없습니다'))
                  : ListView.builder(
                      controller: scrollCtrl,
                      itemCount: records.length,
                      itemBuilder: (ctx, i) {
                        final r = records[records.length - 1 - i]; // 최신 순
                        final color = r.status == AttendanceStatus.present
                            ? AppColors.present
                            : r.status == AttendanceStatus.late
                                ? AppColors.late
                                : AppColors.absent;
                        final label = r.status == AttendanceStatus.present
                            ? '출석'
                            : r.status == AttendanceStatus.late
                                ? '지각'
                                : '결석';

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: color.withValues(alpha: 0.15),
                            child: Text(label[0],
                                style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                          ),
                          title: Text(DateFormat('M월 d일 (E)', 'ko').format(r.date)),
                          subtitle: Text(label),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            onPressed: () async {
                              await ref
                                  .read(attendanceViewModelProvider.notifier)
                                  .delete(r.id);
                              setState(() {});
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusButton(String label, AttendanceStatus status, Color color) {
    final selected = _status == status;
    return Expanded(
      child: OutlinedButton(
        onPressed: () => setState(() => _status = status),
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? color.withValues(alpha: 0.15) : null,
          side: BorderSide(color: selected ? color : Colors.grey.shade300),
          foregroundColor: selected ? color : null,
        ),
        child: Text(label),
      ),
    );
  }

  Future<void> _addRecord() async {
    final record = Attendance(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      courseId: widget.course.id,
      date: _date,
      status: _status,
    );
    await ref.read(attendanceViewModelProvider.notifier).add(record);
    if (mounted) setState(() {});
  }
}
