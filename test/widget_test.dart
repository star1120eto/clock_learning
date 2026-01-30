import 'package:flutter_test/flutter_test.dart';
import 'package:clock_learning/main.dart';

void main() {
  testWidgets('ホーム画面が正しく表示される', (WidgetTester tester) async {
    // アプリをビルド
    await tester.pumpWidget(const MyApp());

    // ホーム画面の要素を確認
    expect(find.text('とけいをまなぼう'), findsOneWidget);
    expect(find.text('とけいをおぼえる'), findsOneWidget);
    expect(find.text('すすみぐあいをみる'), findsOneWidget);
  });

  testWidgets('ホーム画面からレベル選択画面へ遷移できる', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // 「とけいをおぼえる」ボタンをタップ
    await tester.tap(find.text('とけいをおぼえる'));
    await tester.pumpAndSettle();

    // レベル選択画面の要素を確認
    expect(find.text('どのレベルにする？'), findsOneWidget);
    expect(find.text('かんたん'), findsOneWidget);
    expect(find.text('ふつう'), findsOneWidget);
    expect(find.text('むずかしい'), findsOneWidget);
  });
}
