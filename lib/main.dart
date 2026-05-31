import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/screens/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: SpendingChallengeApp()));
}

class SpendingChallengeApp extends StatelessWidget {
  const SpendingChallengeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '소비 반성 일기',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2563EB),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
