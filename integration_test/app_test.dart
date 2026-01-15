import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:clock_learning/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2Eテスト: ユーザーフロー', () {
    testWidgets('ホーム画面からレベル選択、ゲーム開始までのフロー', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle();

      // ホーム画面の確認
      expect(find.text('とけいをまなぼう'), findsOneWidget);
      expect(find.text('とけいをおぼえる'), findsOneWidget);
      expect(find.text('すすみぐあいをみる'), findsOneWidget);

      // 「とけいをおぼえる」ボタンをタップ
      await tester.tap(find.text('とけいをおぼえる'));
      await tester.pumpAndSettle();

      // レベル選択画面の確認
      expect(find.text('どのレベルにする？'), findsOneWidget);
      expect(find.text('かんたん'), findsOneWidget);
      expect(find.text('ふつう'), findsOneWidget);
      expect(find.text('むずかしい'), findsOneWidget);

      // 「かんたん」レベルをタップ
      await tester.tap(find.text('かんたん'));
      await tester.pumpAndSettle();

      // ゲーム画面の確認
      expect(find.text('とけいをあわせてね！'), findsOneWidget);
      expect(find.text('こたえをきめる'), findsOneWidget);
    });

    testWidgets('分針操作から正解判定までのインタラクション', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle();

      // ホーム画面から「とけいをおぼえる」をタップ
      await tester.tap(find.text('とけいをおぼえる'));
      await tester.pumpAndSettle();

      // 「かんたん」レベルをタップ
      await tester.tap(find.text('かんたん'));
      await tester.pumpAndSettle();

      // 時計ウィジェットを探す（CustomPaintで描画されている）
      final clockFinder = find.byType(CustomPaint);
      expect(clockFinder, findsWidgets);

      // 時計の中心座標を取得
      final center = tester.getCenter(clockFinder.first);
      
      // 時計の外周付近をドラッグ（12時の位置から3時の位置へ）
      // 分針を動かすためにドラッグ操作をシミュレート
      final startPoint = Offset(center.dx, center.dy - 100); // 12時の位置
      final endPoint = Offset(center.dx + 100, center.dy); // 3時の位置
      
      await tester.dragFrom(startPoint, endPoint - startPoint);
      await tester.pumpAndSettle();

      // 「こたえをきめる」ボタンをタップ
      await tester.tap(find.text('こたえをきめる'));
      await tester.pumpAndSettle();

      // 結果メッセージが表示されることを確認
      // 正解または不正解のメッセージが表示される
      final hasCorrectMessage = find.text('せいかい！').evaluate().isNotEmpty;
      final hasIncorrectMessage = find.text('ちがいます').evaluate().isNotEmpty;
      expect(hasCorrectMessage || hasIncorrectMessage, true);
    });

    testWidgets('進捗画面でのデータ表示確認', (WidgetTester tester) async {
      // アプリを起動
      app.main();
      await tester.pumpAndSettle();

      // 「すすみぐあいをみる」ボタンをタップ
      await tester.tap(find.text('すすみぐあいをみる'));
      await tester.pumpAndSettle();

      // データ読み込み完了を待つ（ローディングインジケーターが消えるまで）
      // 最大10秒待機
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // 進捗画面の要素を確認
      // AppBarのタイトル
      expect(find.text('しんちょく'), findsOneWidget);
      
      // 統計カードのタイトル
      expect(find.text('せいかいすう'), findsOneWidget);
      expect(find.text('せいかいりつ'), findsOneWidget);
      expect(find.text('れんぞくがくしゅう'), findsOneWidget);
      
      // レベル別進捗のタイトル
      expect(find.text('レベルべつしんちょく'), findsOneWidget);
    });
  });
}
