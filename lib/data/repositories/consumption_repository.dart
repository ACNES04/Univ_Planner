// Data 레이어 책임:
// 데이터베이스, 네트워크, 로컬 메모리 등 구체적인 데이터 출처와 통신하고,
// 그 상세 구현을 상위 레이어에 숨긴다.

import '../../domain/entities/consumption_item.dart';

abstract class ConsumptionRepository {
  List<ConsumptionItem> getSnapshot();
  void addConsumption(ConsumptionItem item);
}

class InMemoryConsumptionRepository implements ConsumptionRepository {
  final List<ConsumptionItem> _items = [
    ConsumptionItem(
      id: 'seed-1',
      title: '스타벅스 커피',
      amount: 5000,
      emotion: '후회',
      reflection: '오후에 피곤해서 충동구매함',
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ConsumptionItem(
      id: 'seed-2',
      title: '전공 서적',
      amount: 35000,
      emotion: '만족',
      reflection: '전공 공부에 꼭 필요한 지출',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ConsumptionItem(
      id: 'seed-3',
      title: '야식 배달',
      amount: 18000,
      emotion: '후회',
      reflection: '배고픔을 못 참고 늦게 주문함',
      date: DateTime.now(),
    ),
  ];

  @override
  List<ConsumptionItem> getSnapshot() {
    return List.unmodifiable(_items);
  }

  @override
  void addConsumption(ConsumptionItem item) {
    _items.add(item);
  }
}
