/// Domain 레이어 책임:
/// 순수 비즈니스 규칙과 데이터 모델을 정의하며,
/// UI/네트워크/DB 같은 외부 기술에 의존하지 않는다.
class ConsumptionItem {
  final String id;
  final String title;
  final int amount;
  final String emotion; // '만족' 또는 '후회'
  final String reflection;
  final DateTime date;

  const ConsumptionItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.emotion,
    required this.reflection,
    required this.date,
  });
}
