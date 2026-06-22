// [Presentation] - 학점 관리 화면: GPA 카드 + 과목별 성적 목록
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/grade_viewmodel.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../domain/entities/grade.dart';

class GradeScreen extends ConsumerStatefulWidget {
  const GradeScreen({super.key});

  @override
  ConsumerState<GradeScreen> createState() => _GradeScreenState();
}

class _GradeScreenState extends ConsumerState<GradeScreen> {
  String? _selectedSemester; // null = 전체

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grades = ref.watch(gradeViewModelProvider);
    final vm = ref.read(gradeViewModelProvider.notifier);
    final semesters = vm.semesters;
    final gpa = _selectedSemester == null
        ? vm.totalGpa
        : vm.gpaForSemester(_selectedSemester!);

    final displayGrades = _selectedSemester == null
        ? grades
        : grades.where((g) => g.semester == _selectedSemester).toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: const Text('학점')),
      body: Column(
        children: [
          // GPA 카드 (인디고 그라데이션)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.indigo600, AppColors.indigo800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedSemester ?? '전체 평점',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  gpa.gpa.toStringAsFixed(2),
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _GpaInfoChip('${gpa.totalCredits}학점'),
                    const SizedBox(width: 8),
                    _GpaInfoChip('${gpa.courseCount}과목'),
                  ],
                ),
              ],
            ),
          ),

          // 학기 필터 탭
          if (semesters.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // 전체 탭
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('전체'),
                      selected: _selectedSemester == null,
                      onSelected: (_) => setState(() => _selectedSemester = null),
                    ),
                  ),
                  ...semesters.map((s) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(s),
                      selected: _selectedSemester == s,
                      onSelected: (_) => setState(() => _selectedSemester = s),
                    ),
                  )),
                ],
              ),
            ),
          const SizedBox(height: 8),

          // 과목 성적 목록
          Expanded(
            child: displayGrades.isEmpty
                ? EmptyState(
                    icon: Icons.school_outlined,
                    title: '성적이 없습니다',
                    ctaLabel: '성적 추가',
                    onCta: () => _showAddSheet(context),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: displayGrades.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) => _GradeCard(grade: displayGrades[i]),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('성적 추가'),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _GradeForm(),
    );
  }
}

// GPA 정보 칩 (그라데이션 카드 위)
class _GpaInfoChip extends StatelessWidget {
  const _GpaInfoChip(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}

// 과목 성적 카드
class _GradeCard extends ConsumerWidget {
  const _GradeCard({required this.grade});
  final Grade grade;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final gradeColor = AppColors.gradeColors[grade.letter.label] ?? AppColors.indigo600;

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
              // 등급 뱃지
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: gradeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  grade.letter.label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: gradeColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      grade.courseName,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      grade.semester,
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
                    '${grade.credit}학점',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${grade.letter.point}',
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
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('성적 삭제'),
        content: Text('\'${grade.courseName}\'을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제')),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(gradeViewModelProvider.notifier).delete(grade.id);
    }
  }
}

// 성적 추가 폼
class _GradeForm extends ConsumerStatefulWidget {
  const _GradeForm();

  @override
  ConsumerState<_GradeForm> createState() => _GradeFormState();
}

class _GradeFormState extends ConsumerState<_GradeForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _semesterCtrl = TextEditingController(text: '2025-1');
  int _credit = 3;
  GradeLetter _letter = GradeLetter.aPlus;

  static const _gradeLetters = GradeLetter.values;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _semesterCtrl.dispose();
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
              Text('성적 추가', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: '과목명'),
                validator: (v) => (v == null || v.isEmpty) ? '과목명을 입력하세요' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _semesterCtrl,
                decoration: const InputDecoration(
                  labelText: '학기',
                  hintText: '예: 2025-1',
                ),
                validator: (v) => (v == null || v.isEmpty) ? '학기를 입력하세요' : null,
              ),
              const SizedBox(height: 16),

              // 학점
              Text('학점', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [1, 2, 3, 4].map((c) => ChoiceChip(
                  label: Text('$c학점'),
                  selected: _credit == c,
                  onSelected: (_) => setState(() => _credit = c),
                )).toList(),
              ),
              const SizedBox(height: 16),

              // 등급 선택
              Text('등급', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _gradeLetters.map((g) {
                  final color = AppColors.gradeColors[g.label] ?? AppColors.indigo600;
                  return ChoiceChip(
                    label: Text(g.label),
                    selected: _letter == g,
                    selectedColor: color.withValues(alpha: 0.2),
                    onSelected: (_) => setState(() => _letter = g),
                  );
                }).toList(),
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
    final grade = Grade(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      courseName: _nameCtrl.text.trim(),
      credit: _credit,
      letter: _letter,
      semester: _semesterCtrl.text.trim(),
    );
    await ref.read(gradeViewModelProvider.notifier).add(grade);
    if (mounted) Navigator.pop(context);
  }
}
