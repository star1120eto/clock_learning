import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clock_learning/widgets/parental_gate.dart';

/// ダイアログに表示されている「NN × N = ?」から正解を取り出す
int _answerFromQuestion(WidgetTester tester) {
  final text = tester
      .widgetList<Text>(find.byType(Text))
      .map((w) => w.data)
      .whereType<String>()
      .firstWhere((s) => s.contains('×'));
  final match = RegExp(r'(\d+)\s*×\s*(\d+)').firstMatch(text)!;
  return int.parse(match.group(1)!) * int.parse(match.group(2)!);
}

/// ゲートを開くだけのテスト用ホスト
Widget _host(void Function(bool) onResult) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async => onResult(await ParentalGate.show(context)),
          child: const Text('open'),
        ),
      ),
    ),
  );
}

void main() {
  group('ParentalGate', () {
    testWidgets('正解を入力すると true を返す', (tester) async {
      bool? result;
      await tester.pumpWidget(_host((r) => result = r));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('保護者の方へ'), findsOneWidget);

      await tester.enterText(
        find.byType(TextField),
        '${_answerFromQuestion(tester)}',
      );
      await tester.tap(find.text('確認'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(find.text('保護者の方へ'), findsNothing);
    });

    testWidgets('キャンセルすると false を返す', (tester) async {
      bool? result;
      await tester.pumpWidget(_host((r) => result = r));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('キャンセル'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets('誤答するとエラーを表示し、問題が差し替わる', (tester) async {
      await tester.pumpWidget(_host((_) {}));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final firstAnswer = _answerFromQuestion(tester);
      await tester.enterText(find.byType(TextField), '${firstAnswer + 1}');
      await tester.tap(find.text('確認'));
      await tester.pumpAndSettle();

      // ダイアログは開いたままで、残り回数つきのエラーが出る
      expect(find.text('保護者の方へ'), findsOneWidget);
      expect(find.textContaining('答えが違います'), findsOneWidget);
      // 入力欄はクリアされている
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
          isEmpty);
    });

    testWidgets('3回誤答すると false を返して閉じる', (tester) async {
      bool? result;
      await tester.pumpWidget(_host((r) => result = r));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      for (var i = 0; i < 3; i++) {
        await tester.enterText(
          find.byType(TextField),
          '${_answerFromQuestion(tester) + 1}',
        );
        await tester.tap(find.text('確認'));
        await tester.pumpAndSettle();
      }

      expect(result, isFalse);
      expect(find.text('保護者の方へ'), findsNothing);
    });

    testWidgets('ダイアログ外タップでは閉じない', (tester) async {
      await tester.pumpWidget(_host((_) {}));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('保護者の方へ'), findsOneWidget);
    });
  });
}
