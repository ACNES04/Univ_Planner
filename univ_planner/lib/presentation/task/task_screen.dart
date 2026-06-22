// [Presentation] - 과제 관리 화면: 완료/미완료 탭 + 과제 추가 BottomSheet
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../application/task_viewmodel.dart';
import '../../application/timetable_viewmodel.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../domain/entities/task.dart';

class TaskScreen extends ConsumerStatefulWidget {
  const TaskScreen({super.key});

  @override
  ConsumerState<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends ConsumerState<TaskScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    ref.watch(taskViewModelProvider);
    final vm = ref.read(taskViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('과제'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '미완료'),
            Tab(text: '완료'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TaskList(tasks: vm.pending, isPending: true),
          _TaskList(tasks: vm.done, isPending: false),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('과제 추가'),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _TaskForm(),
    );
  }
}

// 과제 목록
class _TaskList extends ConsumerWidget {
  const _TaskList({required this.tasks, required this.isPending});
  final List<Task> tasks;
  final bool isPending;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tasks.isEmpty) {
      return EmptyState(
        icon: isPending ? Icons.assignment_outlined : Icons.task_alt,
        title: isPending ? '과제가 없습니다' : '완료된 과제가 없습니다',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) => _TaskCard(task: tasks[i]),
    );
  }
}

// 과제 카드
class _TaskCard extends ConsumerWidget {
  const _TaskCard({required this.task});
  final Task task;

  // 우선순위 색상
  static const _priorityColors = [
    AppColors.categoryEtc, // 낮음 - 회색
    AppColors.categoryAcademic, // 보통 - 파랑
    AppColors.danger, // 높음 - 빨강
  ];
  static const _priorityLabels = ['낮음', '보통', '높음'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final courses = ref.watch(timetableViewModelProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadline = DateTime(task.deadline.year, task.deadline.month, task.deadline.day);
    final diff = deadline.difference(today).inDays;
    final priorityColor = _priorityColors[task.priority.clamp(0, 2)];

    // 과목명 조회
    final courseName = task.courseId != null
        ? courses.where((c) => c.id == task.courseId).firstOrNull?.name
        : null;

    // D-Day 배지
    final String dDay;
    final Color dDayColor;
    if (task.isDone) {
      dDay = '완료';
      dDayColor = AppColors.success;
    } else if (diff < 0) {
      dDay = '만료';
      dDayColor = AppColors.categoryEtc;
    } else if (diff == 0) {
      dDay = 'D-Day';
      dDayColor = AppColors.danger;
    } else {
      dDay = 'D-$diff';
      dDayColor = diff <= 1 ? AppColors.danger : AppColors.warning;
    }

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
              // 우선순위 색상 바
              Container(width: 4, color: priorityColor),
              // 체크박스
              Checkbox(
                value: task.isDone,
                onChanged: (_) =>
                    ref.read(taskViewModelProvider.notifier).toggleDone(task.id),
                activeColor: theme.colorScheme.primary,
              ),
              // 내용
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: task.isDone ? TextDecoration.lineThrough : null,
                          color: task.isDone ? theme.colorScheme.onSurfaceVariant : null,
                        ),
                      ),
                      if (courseName != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            courseName,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('M월 d일 HH:mm', 'ko').format(task.deadline),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // D-Day + 우선순위
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: dDayColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        dDay,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: dDayColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _priorityLabels[task.priority.clamp(0, 2)],
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: priorityColor,
                      ),
                    ),
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
        title: const Text('과제 삭제'),
        content: Text('\'${task.title}\'을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제')),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(taskViewModelProvider.notifier).delete(task.id);
    }
  }
}

// 과제 추가 폼
class _TaskForm extends ConsumerStatefulWidget {
  const _TaskForm();

  @override
  ConsumerState<_TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends ConsumerState<_TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _memoCtrl = TextEditingController();
  DateTime _deadline = DateTime.now().add(const Duration(days: 7));
  int _priority = 1;
  String? _courseId;

  static const _priorityLabels = ['낮음', '보통', '높음'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _memoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final courses = ref.watch(timetableViewModelProvider);

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
              Text('과제 추가', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: '과제 제목'),
                validator: (v) => (v == null || v.isEmpty) ? '제목을 입력하세요' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _memoCtrl,
                decoration: const InputDecoration(labelText: '메모 (선택)'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // 마감일 선택
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.schedule),
                title: Text(DateFormat('yyyy년 M월 d일 HH:mm', 'ko').format(_deadline)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickDeadline,
              ),
              const Divider(),
              const SizedBox(height: 8),

              // 우선순위
              Text('우선순위', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(3, (i) => ChoiceChip(
                  label: Text(_priorityLabels[i]),
                  selected: _priority == i,
                  onSelected: (_) => setState(() => _priority = i),
                )),
              ),
              const SizedBox(height: 16),

              // 과목 연결 드롭다운
              if (courses.isNotEmpty) ...[
                Text('과목 연결 (선택)', style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                DropdownButtonFormField<String?>(
                  initialValue: _courseId,
                  decoration: const InputDecoration(labelText: '과목 선택'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('없음')),
                    ...courses.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                  ],
                  onChanged: (v) => setState(() => _courseId = v),
                ),
                const SizedBox(height: 16),
              ],

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

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deadline),
    );
    if (time == null) return;

    setState(() {
      _deadline = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      courseId: _courseId,
      deadline: _deadline,
      memo: _memoCtrl.text.trim(),
      priority: _priority,
    );
    await ref.read(taskViewModelProvider.notifier).add(task);
    if (mounted) Navigator.pop(context);
  }
}
