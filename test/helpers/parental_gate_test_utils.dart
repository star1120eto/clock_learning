import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 表示されている保護者ゲートのダイアログから「NN × N = ?」を読み取り、正解を返す。
int answerFromQuestion(WidgetTester tester) {
  final text = tester
      .widgetList<Text>(find.byType(Text))
      .map((w) => w.data)
      .whereType<String>()
      .firstWhere((s) => s.contains('×'));
  final match = RegExp(r'(\d+)\s*×\s*(\d+)').firstMatch(text)!;
  return int.parse(match.group(1)!) * int.parse(match.group(2)!);
}
