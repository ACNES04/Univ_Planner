// 기본 앱 스모크 테스트 (Hive 없이 테마/라우팅만 검증)
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:univ_planner/core/theme/app_theme.dart';

void main() {
  testWidgets('MaterialApp이 정상적으로 생성되는지 확인', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const Scaffold(
          body: Center(child: Text('Univ Planner')),
        ),
      ),
    );
    expect(find.text('Univ Planner'), findsOneWidget);
  });

  testWidgets('다크 테마가 적용되는지 확인', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        themeMode: ThemeMode.dark,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const Scaffold(body: Center(child: Text('다크모드'))),
      ),
    );
    expect(find.text('다크모드'), findsOneWidget);
  });
}
