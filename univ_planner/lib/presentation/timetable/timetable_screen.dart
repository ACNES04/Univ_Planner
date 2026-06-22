// [Presentation] - 시간표 화면: 요일별 과목 목록 + 과목 추가 BottomSheet
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/timetable_viewmodel.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../domain/entities/course.dart';

class TimetableScreen extends ConsumerStatefulWidget {
  const TimetableScreen({super.key});

  @override
  ConsumerState<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends ConsumerState<TimetableScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<String> _days = ['월', '화', '수', '목', '금'];

  @override
  void initState() {
    super.initState();
    // 오늘 요일에 맞는 탭으로 초기화 (주말이면 0번 탭)
    final weekday = DateTime.now().weekday;
    final initial = (weekday >= 1 && weekday <= 5) ? weekday - 1 : 0;
    _tabController = TabController(length: 5, vsync: this, initialIndex: initial);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('시간표'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _days.map((d) => Tab(text: d)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(5, (i) => _DayTab(dayOfWeek: i + 1)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('과목 추가'),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _CourseForm(),
    );
  }
}

// 요일별 과목 탭
class _DayTab extends ConsumerWidget {
  const _DayTab({required this.dayOfWeek});
  final int dayOfWeek;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(timetableViewModelProvider.notifier).coursesByDay(dayOfWeek);
    // watch로 상태 변화 감지
    ref.watch(timetableViewModelProvider);

    if (courses.isEmpty) {
      return const EmptyState(
        icon: Icons.table_chart_outlined,
        title: '수업이 없습니다',
        description: '아래 버튼으로 과목을 추가하세요',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: courses.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) => _CourseCard(course: courses[i]),
    );
  }
}

// 과목 카드
class _CourseCard extends ConsumerWidget {
  const _CourseCard({required this.course});
  final Course course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = Color(course.colorValue);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onLongPress: () => _confirmDelete(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 6, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
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
                          const SizedBox(height: 2),
                          Text(
                            '${course.credit}학점',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('과목 삭제'),
        content: Text('\'${course.name}\'을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제')),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(timetableViewModelProvider.notifier).delete(course.id);
    }
  }
}

// 과목 추가 폼 BottomSheet
class _CourseForm extends ConsumerStatefulWidget {
  const _CourseForm();

  @override
  ConsumerState<_CourseForm> createState() => _CourseFormState();
}

class _CourseFormState extends ConsumerState<_CourseForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _profCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  int _dayOfWeek = 1;
  int _startHour = 9;
  int _endHour = 11;
  int _credit = 3;
  int _colorIndex = 0;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _profCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayLabels = ['월', '화', '수', '목', '금'];

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('과목 추가', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: '과목명'),
                validator: (v) => (v == null || v.isEmpty) ? '과목명을 입력하세요' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _profCtrl,
                decoration: const InputDecoration(labelText: '교수명'),
                validator: (v) => (v == null || v.isEmpty) ? '교수명을 입력하세요' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(labelText: '강의실'),
              ),
              const SizedBox(height: 16),

              // 요일 선택
              Text('요일', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(5, (i) {
                  final selected = _dayOfWeek == i + 1;
                  return ChoiceChip(
                    label: Text(dayLabels[i]),
                    selected: selected,
                    onSelected: (_) => setState(() => _dayOfWeek = i + 1),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // 시작/종료 시간
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('시작 시각', style: theme.textTheme.labelLarge),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          initialValue: _startHour,
                          items: List.generate(
                            15,
                            (i) => DropdownMenuItem(value: i + 8, child: Text('${i + 8}:00')),
                          ),
                          onChanged: (v) => setState(() => _startHour = v!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('종료 시각', style: theme.textTheme.labelLarge),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          initialValue: _endHour,
                          items: List.generate(
                            15,
                            (i) => DropdownMenuItem(value: i + 9, child: Text('${i + 9}:00')),
                          ),
                          onChanged: (v) => setState(() => _endHour = v!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 학점
              Text('학점', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [1, 2, 3, 4].map((c) {
                  return ChoiceChip(
                    label: Text('$c학점'),
                    selected: _credit == c,
                    onSelected: (_) => setState(() => _credit = c),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // 색상 선택
              Text('색상', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(AppColors.courseColors.length, (i) {
                  final selected = _colorIndex == i;
                  return GestureDetector(
                    onTap: () => setState(() => _colorIndex = i),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.courseColors[i],
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(color: theme.colorScheme.onSurface, width: 2)
                            : null,
                      ),
                      child: selected
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                }),
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
    if (_endHour <= _startHour) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('종료 시각은 시작 시각보다 늦어야 합니다')),
      );
      return;
    }

    final course = Course(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      professor: _profCtrl.text.trim(),
      credit: _credit,
      dayOfWeek: _dayOfWeek,
      startHour: _startHour,
      endHour: _endHour,
      location: _locationCtrl.text.trim(),
      colorValue: AppColors.courseColors[_colorIndex].toARGB32(),
    );

    await ref.read(timetableViewModelProvider.notifier).add(course);
    if (mounted) Navigator.pop(context);
  }
}
