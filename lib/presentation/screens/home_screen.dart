// Presentation 레이어 책임:
// 사용자 화면을 렌더링하고 입력 이벤트를 감지하며,
// Application 레이어 상태 변화를 UI에 반영한다.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/view_models/consumption_view_model.dart';
import '../../domain/entities/consumption_item.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(consumptionViewModelProvider);
    final viewModel = ref.read(consumptionViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('소비 반성 일기'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF0EA5E9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.20),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Text(
              '🔥 후회 없는 소비 챌린지 3일차 성공 진행 중!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('아직 등록된 소비 반성 일기가 없습니다.'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return _ConsumptionCard(item: items[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, viewModel),
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('소비 기록하기'),
      ),
    );
  }

  void _showAddDialog(BuildContext context, ConsumptionViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _AddConsumptionSheet(viewModel: viewModel),
    );
  }
}

class _ConsumptionCard extends StatelessWidget {
  final ConsumptionItem item;
  const _ConsumptionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isRegret = item.emotion == '후회';
    final accent = isRegret ? const Color(0xFFDC2626) : const Color(0xFF2563EB);
    final bg = isRegret ? const Color(0xFFFEECEC) : const Color(0xFFEFF6FF);
    final icon = isRegret ? Icons.warning_amber_rounded : Icons.thumb_up_alt_rounded;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: accent.withValues(alpha: 0.14),
          child: Icon(icon, color: accent),
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('[${item.emotion}] ${item.reflection}'),
        ),
        trailing: Text(
          '${item.amount}원',
          style: TextStyle(color: accent, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _AddConsumptionSheet extends StatefulWidget {
  final ConsumptionViewModel viewModel;
  const _AddConsumptionSheet({required this.viewModel});

  @override
  State<_AddConsumptionSheet> createState() => _AddConsumptionSheetState();
}

class _AddConsumptionSheetState extends State<_AddConsumptionSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _reflectionController = TextEditingController();
  String _emotion = '후회';

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _reflectionController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final amount = int.tryParse(_amountController.text.trim()) ?? 0;
    final reflection = _reflectionController.text.trim();

    if (title.isEmpty || amount <= 0 || reflection.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 항목을 올바르게 입력해 주세요.')),
      );
      return;
    }

    widget.viewModel.addConsumption(
      title: title,
      amount: amount,
      emotion: _emotion,
      reflection: reflection,
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '새 소비 기록 등록',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: '지출명',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '금액',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          const Text('감정 선택'),
          RadioGroup<String>(
            groupValue: _emotion,
            onChanged: (value) => setState(() => _emotion = value ?? _emotion),
            child: const Column(
              children: [
                RadioListTile<String>(
                  value: '만족',
                  contentPadding: EdgeInsets.zero,
                  title: Text('만족'),
                ),
                RadioListTile<String>(
                  value: '후회',
                  contentPadding: EdgeInsets.zero,
                  title: Text('후회'),
                ),
              ],
            ),
          ),
          TextField(
            controller: _reflectionController,
            decoration: const InputDecoration(
              labelText: '반성 한 줄',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              child: const Text('등록하기'),
            ),
          ),
        ],
      ),
    );
  }
}
