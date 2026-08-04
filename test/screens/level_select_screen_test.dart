import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clock_learning/screens/level_select_screen.dart';
import 'package:clock_learning/screens/paywall_screen.dart';
import 'package:clock_learning/services/subscription_service.dart';

import '../helpers/fake_in_app_purchase_platform.dart';
import '../helpers/parental_gate_test_utils.dart';

Future<void> _settle() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

Future<void> _pumpLevelSelect(
  WidgetTester tester,
  SubscriptionService service,
) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<SubscriptionService>.value(
      value: service,
      child: const MaterialApp(
        home: LevelSelectScreen(mode: LevelSelectMode.game),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const prefsChannel = MethodChannel('plugins.flutter.io/shared_preferences');
  const audioChannel = MethodChannel('xyz.luan/audioplayers');
  late FakeInAppPurchasePlatform fake;

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(prefsChannel, (MethodCall call) async {
      if (call.method == 'getAll') return <String, dynamic>{};
      return null;
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioChannel, (MethodCall call) async => null);
    SharedPreferences.setMockInitialValues({});

    fake = FakeInAppPurchasePlatform();
    installFakeInAppPurchasePlatform(fake);
    SubscriptionService.restoreGraceDelay = Duration.zero;
  });

  tearDown(() async {
    SubscriptionService.restoreGraceDelay = const Duration(seconds: 2);
    await fake.dispose();
  });

  group('LevelSelectScreen（プレミアムゲーティング）', () {
    testWidgets('未加入の場合、ふつう・むずかしいがロックされバナーが表示される', (tester) async {
      final service = SubscriptionService();
      await _settle();

      await _pumpLevelSelect(tester, service);

      expect(find.text('プレミアム'), findsNWidgets(2));
      expect(find.byIcon(Icons.lock), findsNWidgets(2));
      expect(find.text('プレミアムプランでもっとたのしもう！'), findsOneWidget);
    });

    testWidgets('ロック中カードをタップ→ゲート正解→ペイウォールが開く', (tester) async {
      final service = SubscriptionService();
      await _settle();

      await _pumpLevelSelect(tester, service);

      await tester.tap(find.text('ふつう'));
      await tester.pumpAndSettle();

      expect(find.text('保護者の方へ'), findsOneWidget);

      await tester.enterText(
        find.byType(TextField),
        '${answerFromQuestion(tester)}',
      );
      await tester.tap(find.text('確認'));
      await tester.pumpAndSettle();

      expect(find.byType(PaywallScreen), findsOneWidget);
    });

    testWidgets('ゲートをキャンセルするとペイウォールへ進まない', (tester) async {
      final service = SubscriptionService();
      await _settle();

      await _pumpLevelSelect(tester, service);

      await tester.tap(find.text('むずかしい'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('キャンセル'));
      await tester.pumpAndSettle();

      expect(find.byType(PaywallScreen), findsNothing);
      expect(find.text('どのレベルにする？'), findsOneWidget);
    });

    testWidgets('ゲートで3回誤答するとペイウォールへ進まない', (tester) async {
      final service = SubscriptionService();
      await _settle();

      await _pumpLevelSelect(tester, service);

      await tester.tap(find.text('ふつう'));
      await tester.pumpAndSettle();

      for (var i = 0; i < 3; i++) {
        await tester.enterText(
          find.byType(TextField),
          '${answerFromQuestion(tester) + 1}',
        );
        await tester.tap(find.text('確認'));
        await tester.pumpAndSettle();
      }

      expect(find.byType(PaywallScreen), findsNothing);
      expect(find.text('どのレベルにする？'), findsOneWidget);
    });

    testWidgets('プレミアムバナーのタップでも同じゲートを経てペイウォールが開く', (tester) async {
      final service = SubscriptionService();
      await _settle();

      await _pumpLevelSelect(tester, service);

      await tester.ensureVisible(find.text('プレミアムプランでもっとたのしもう！'));
      await tester.pump();
      await tester.tap(find.text('プレミアムプランでもっとたのしもう！'));
      await tester.pumpAndSettle();

      expect(find.text('保護者の方へ'), findsOneWidget);

      await tester.enterText(
        find.byType(TextField),
        '${answerFromQuestion(tester)}',
      );
      await tester.tap(find.text('確認'));
      await tester.pumpAndSettle();

      expect(find.byType(PaywallScreen), findsOneWidget);
    });

    testWidgets('加入済みの場合、ロックなしでゲートを経由せず直接遷移する', (tester) async {
      // GameScreen の Column が既定の 800x600 テスト画面には収まらないため
      // 表面を拡大する（test/widget_test.dart と同じ対処）。
      tester.view.physicalSize = const ui.Size(800, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.physicalSize = const ui.Size(800, 600);
        tester.view.devicePixelRatio = 1.0;
      });

      SharedPreferences.setMockInitialValues({'is_premium': true});
      final service = SubscriptionService();
      await _settle();

      await _pumpLevelSelect(tester, service);

      expect(find.text('プレミアム'), findsNothing);
      expect(find.byIcon(Icons.lock), findsNothing);
      expect(find.text('プレミアムプランでもっとたのしもう！'), findsNothing);

      await tester.tap(find.text('ふつう'));
      await tester.pumpAndSettle();

      expect(find.text('保護者の方へ'), findsNothing);
      expect(find.byType(PaywallScreen), findsNothing);
    });
  });
}
