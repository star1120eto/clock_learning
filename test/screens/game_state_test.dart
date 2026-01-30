import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:clock_learning/models/level.dart';
import 'package:clock_learning/screens/game_screen.dart';
import 'package:clock_learning/widgets/clock_controller.dart';
import 'package:clock_learning/services/problem_generator_service.dart';
import 'package:clock_learning/services/progress_service.dart';
import 'package:clock_learning/services/audio_service.dart';
import 'package:clock_learning/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameState（next-problem-after-wrong）', () {
    const MethodChannel channel = MethodChannel('plugins.flutter.io/shared_preferences');
    const MethodChannel audioChannel = MethodChannel('xyz.luan/audioplayers');
    late GameState gameState;
    late ClockController clockController;

    setUp(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'getAll') return <String, dynamic>{};
        return null;
      });
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(audioChannel, (MethodCall methodCall) async => null);
      SharedPreferences.setMockInitialValues({});

      final storageService = await StorageService.create();
      final progressService = ProgressService(storageService);
      final audioService = await AudioService.create();
      clockController = ClockController();
      final problemGenerator = ProblemGeneratorService();

      gameState = GameState(
        level: Level.easy,
        clockController: clockController,
        problemGenerator: problemGenerator,
        progressService: progressService,
        audioService: audioService,
      );
    });

    tearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(audioChannel, null);
    });

    test('不正解のときは自動で次の問題に進まない', () async {
      gameState.startGame();
      final problemBefore = gameState.currentProblem;
      expect(problemBefore, isNotNull);

      // 意図的に不正解になるよう時計を合わせる（かんたんは正時のみ。正解以外に設定）
      final targetHour = problemBefore!.targetTime.hour;
      final wrongHour = targetHour == 12 ? 1 : targetHour + 1;
      clockController.initialize(wrongHour, 0, Level.easy);

      await gameState.checkAnswer();

      expect(gameState.lastResult, false);
      expect(gameState.currentProblem, same(problemBefore));
    });

    test('goToNextProblem を呼ぶと次の問題に進む', () async {
      gameState.startGame();
      final problemBefore = gameState.currentProblem!;
      clockController.initialize(
        problemBefore.targetTime.hour == 12 ? 1 : problemBefore.targetTime.hour + 1,
        0,
        Level.easy,
      );
      await gameState.checkAnswer();
      expect(gameState.lastResult, false);

      gameState.goToNextProblem();

      expect(gameState.lastResult, isNull);
      expect(gameState.currentProblem, isNotNull);
    });
  });
}
