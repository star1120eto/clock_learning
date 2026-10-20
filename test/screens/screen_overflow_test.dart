import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:clock_learning/models/level.dart';
import 'package:clock_learning/screens/clock_reading_screen.dart';
import 'package:clock_learning/screens/free_play_screen.dart';
import 'package:clock_learning/screens/game_screen.dart';
import 'package:clock_learning/screens/home_screen.dart';
import 'package:clock_learning/screens/level_select_screen.dart';
import 'package:clock_learning/screens/onboarding_screen.dart';
import 'package:clock_learning/screens/paywall_screen.dart';
import 'package:clock_learning/screens/progress_screen.dart';
import 'package:clock_learning/screens/result_screen.dart';
import 'package:clock_learning/screens/settings_screen.dart';
import 'package:clock_learning/screens/sticker_book_screen.dart';
import 'package:clock_learning/services/daily_challenge_service.dart';
import 'package:clock_learning/services/sticker_service.dart';
import 'package:clock_learning/services/subscription_service.dart';

/// 検証対象の画面サイズ。
///
/// iPhone 専用ビルドを iPad で起動すると互換モードで縦幅が狭くなるため、
/// もっとも厳しい 320x568（iPhone SE 相当）を下限として含めている。
const _viewports = <String, ui.Size>{
  'iPhone SE 320x568': ui.Size(320, 568),
  'iPhone 375x667': ui.Size(375, 667),
  'iPhone Pro Max 430x932': ui.Size(430, 932),
  'iPad portrait 768x1024': ui.Size(768, 1024),
};

Widget _wrap(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SubscriptionService()),
      ChangeNotifierProvider(create: (_) => StickerService()),
      ChangeNotifierProvider(create: (_) => DailyChallengeService()),
    ],
    child: MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: child,
    ),
  );
}

/// 画面を指定サイズで描画し、オーバーフローが発生しないことを検証する。
Future<void> _expectNoOverflow(
  WidgetTester tester,
  Widget screen,
  ui.Size size,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(_wrap(screen));

  // 非同期初期化（SharedPreferences・AudioService など）と
  // 短いアニメーションの完了を待つ。無限アニメーションがある画面でも
  // 止まらないよう pumpAndSettle は使わない。
  for (var i = 0; i < 15; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }

  final messages = <String>[];
  Object? error = tester.takeException();
  while (error != null) {
    messages.add(error.toString());
    error = tester.takeException();
  }

  final overflows = messages.where((m) => m.contains('overflowed')).toList();
  expect(overflows, isEmpty, reason: 'オーバーフローが発生: ${overflows.join('\n')}');
}

void main() {
  const sharedPrefsChannel = MethodChannel(
    'plugins.flutter.io/shared_preferences',
  );
  const audioChannel = MethodChannel('xyz.luan/audioplayers');

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(sharedPrefsChannel, (MethodCall call) async {
          if (call.method == 'getAll') return <String, dynamic>{};
          return null;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          audioChannel,
          (MethodCall call) async => null,
        );
    SharedPreferences.setMockInitialValues({});
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(sharedPrefsChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioChannel, null);
  });

  /// 画面ごとに全ビューポートでテストを登録する。
  void testScreen(String name, Widget Function() build) {
    group(name, () {
      _viewports.forEach((label, size) {
        testWidgets('$label でオーバーフローしない', (tester) async {
          await _expectNoOverflow(tester, build(), size);
        });
      });
    });
  }

  testScreen('オンボーディング画面', () => const OnboardingScreen());
  testScreen('ホーム画面', () => const HomeScreen());
  testScreen(
    'レベル選択画面（よみとり）',
    () => const LevelSelectScreen(mode: LevelSelectMode.reading),
  );
  testScreen(
    'レベル選択画面（とけいあわせ）',
    () => const LevelSelectScreen(mode: LevelSelectMode.game),
  );
  testScreen('じゆうにさわる画面', () => const FreePlayScreen());
  testScreen('すすみぐあい画面', () => const ProgressScreen());
  testScreen('シールブック画面', () => const StickerBookScreen());
  testScreen('せってい画面', () => const SettingsScreen());
  testScreen('課金画面', () => const PaywallScreen());

  for (final level in Level.values) {
    testScreen('よみとり画面（${level.name}）', () => ClockReadingScreen(level: level));
    testScreen('とけいあわせ画面（${level.name}）', () => GameScreen(level: level));
  }

  testScreen(
    'けっか画面（全問正解）',
    () => const ResultScreen(
      correctCount: 5,
      incorrectCount: 0,
      level: Level.easy,
    ),
  );
  testScreen(
    'けっか画面（全問不正解）',
    () => const ResultScreen(
      correctCount: 0,
      incorrectCount: 5,
      level: Level.hard,
    ),
  );
}
