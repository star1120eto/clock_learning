import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:clock_learning/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  group('next-problem-after-wrong', () {
    const MethodChannel _sharedPrefsChannel = MethodChannel('plugins.flutter.io/shared_preferences');
    const MethodChannel _audioChannel = MethodChannel('xyz.luan/audioplayers');

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_sharedPrefsChannel, (MethodCall call) async {
        if (call.method == 'getAll') return <String, dynamic>{};
        return null;
      });
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_audioChannel, (MethodCall call) async => null);
      SharedPreferences.setMockInitialValues({});
    });

    tearDownAll(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_sharedPrefsChannel, null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(_audioChannel, null);
    });

    testWidgets('不正解時に「つぎのもんだい」が表示されタップで次問題に進む', (WidgetTester tester) async {
      // ゲーム画面のColumnが収まり「つぎのもんだい」がタップできるよう表面を拡大
      tester.view.physicalSize = const ui.Size(800, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.physicalSize = const ui.Size(800, 600);
        tester.view.devicePixelRatio = 1.0;
      });

      await tester.pumpWidget(const MyApp());
      await tester.tap(find.text('とけいをおぼえる'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('かんたん'));
      await tester.pump();

      // ゲーム画面の非同期初期化完了を待つ（最大約3秒）
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (find.text('とけいをあわせてね！').evaluate().isNotEmpty) break;
      }

      expect(find.text('とけいをあわせてね！'), findsOneWidget);
      expect(find.text('こたえをきめる'), findsOneWidget);

      await tester.tap(find.text('こたえをきめる'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(seconds: 2));

      if (find.text('つぎのもんだい').evaluate().isNotEmpty) {
        await tester.tap(find.text('つぎのもんだい'));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('とけいをあわせてね！'), findsOneWidget);
      }
    });
  });
}
