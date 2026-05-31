// Application 레이어 책임:
// 사용자 유스케이스를 조율하고 Domain과 UI 사이의 데이터 흐름을 제어한다.
// Presentation은 이 레이어의 상태만 구독하고, Data 접근은 직접 수행하지 않는다.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/consumption_repository.dart';
import '../../domain/entities/consumption_item.dart';

final consumptionRepositoryProvider = Provider<ConsumptionRepository>((ref) {
  return InMemoryConsumptionRepository();
});

class ConsumptionViewModel extends StateNotifier<List<ConsumptionItem>> {
  final ConsumptionRepository _repository;

  ConsumptionViewModel(this._repository)
      : super(_sortByLatest(_repository.getSnapshot()));

  static List<ConsumptionItem> _sortByLatest(List<ConsumptionItem> items) {
    final sorted = [...items]..sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(sorted);
  }

  void addConsumption({
    required String title,
    required int amount,
    required String emotion,
    required String reflection,
  }) {
    final newItem = ConsumptionItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      emotion: emotion,
      reflection: reflection,
      date: DateTime.now(),
    );

    _repository.addConsumption(newItem);
    state = _sortByLatest(_repository.getSnapshot());
  }
}

final consumptionViewModelProvider =
    StateNotifierProvider<ConsumptionViewModel, List<ConsumptionItem>>((ref) {
  final repository = ref.read(consumptionRepositoryProvider);
  return ConsumptionViewModel(repository);
});
