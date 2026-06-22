// [Presentation] - 학사일정 화면: 캘린더 + 일정 추가 BottomSheet
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../application/calendar_viewmodel.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../domain/entities/academic_schedule.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focused = DateTime.now();
  DateTime _selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final schedules = ref.watch(calendarViewModelProvider);
    final vm = ref.read(calendarViewModelProvider.notifier);
    final daySchedules = vm.schedulesForDay(_selected);

    // 날짜별 이벤트 맵
    Map<DateTime, List<AcademicSchedule>> eventMap = {};
    for (final s in schedules) {
      final key = DateTime(s.date.year, s.date.month, s.date.day);
      eventMap.putIfAbsent(key, () => []).add(s);
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: const Text('학사일정')),
      body: Column(
        children: [
          // 캘린더 위젯
          TableCalendar<AcademicSchedule>(
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            focusedDay: _focused,
            selectedDayPredicate: (d) => isSameDay(d, _selected),
            eventLoader: (d) {
              final key = DateTime(d.year, d.month, d.day);
              return eventMap[key] ?? [];
            },
            onDaySelected: (selected, focused) {
              setState(() {
                _selected = selected;
                _focused = focused;
              });
            },
            onPageChanged: (focused) => setState(() => _focused = focused),
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(color: theme.colorScheme.onPrimaryContainer),
              markerDecoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(formatButtonVisible: false),
          ),

          const Divider(height: 1),

          // 선택된 날짜 일정 목록
          Expanded(
            child: daySchedules.isEmpty
                ? EmptyState(
                    icon: Icons.event_note,
                    title: '${DateFormat('M월 d일', 'ko').format(_selected)} 일정 없음',
                    ctaLabel: '일정 추가',
                    onCta: () => _showAddSheet(context),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: daySchedules.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) => _ScheduleCard(schedule: daySchedules[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('일정 추가'),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ScheduleForm(selectedDate: _selected),
    );
  }
}

// 일정 카드
class _ScheduleCard extends ConsumerWidget {
  const _ScheduleCard({required this.schedule});
  final AcademicSchedule schedule;

  static const _catLabels = ['학사', '시험', '휴일', '기타'];
  static const _catColors = [
    AppColors.categoryAcademic,
    AppColors.categoryExam,
    AppColors.categoryHoliday,
    AppColors.categoryEtc,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final catIndex = schedule.category.clamp(0, 3);
    final color = _catColors[catIndex];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onLongPress: () => _confirmDelete(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _catLabels[catIndex],
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.title,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (schedule.memo.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        schedule.memo,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('일정 삭제'),
        content: Text('\'${schedule.title}\'을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제')),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(calendarViewModelProvider.notifier).delete(schedule.id);
    }
  }
}

// 일정 추가 폼
class _ScheduleForm extends ConsumerStatefulWidget {
  const _ScheduleForm({required this.selectedDate});
  final DateTime selectedDate;

  @override
  ConsumerState<_ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends ConsumerState<_ScheduleForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _memoCtrl = TextEditingController();
  int _category = 0;

  static const _catLabels = ['학사', '시험', '휴일', '기타'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _memoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('일정 추가', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              Text(
                DateFormat('M월 d일 (E)', 'ko').format(widget.selectedDate),
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: '제목'),
                validator: (v) => (v == null || v.isEmpty) ? '제목을 입력하세요' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _memoCtrl,
                decoration: const InputDecoration(labelText: '메모 (선택)'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              Text('카테고리', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(_catLabels.length, (i) => ChoiceChip(
                  label: Text(_catLabels[i]),
                  selected: _category == i,
                  onSelected: (_) => setState(() => _category = i),
                )),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submit,
                  child: const Text('추가하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final schedule = AcademicSchedule(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      date: widget.selectedDate,
      memo: _memoCtrl.text.trim(),
      category: _category,
    );
    await ref.read(calendarViewModelProvider.notifier).add(schedule);
    if (mounted) Navigator.pop(context);
  }
}
