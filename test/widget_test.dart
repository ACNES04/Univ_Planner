import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spending_challenge/main.dart';

void main() {
  testWidgets('홈 화면 기본 렌더링', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SpendingChallengeApp(),
      ),
    );

    expect(find.text('소비 반성 일기'), findsOneWidget);
    expect(find.text('소비 기록하기'), findsOneWidget);
  });

  testWidgets('소비 기록 바텀시트 열기', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SpendingChallengeApp(),
      ),
    );

    await tester.tap(find.text('소비 기록하기'));
    await tester.pumpAndSettle();

    expect(find.text('등록하기'), findsOneWidget);
  });
}
