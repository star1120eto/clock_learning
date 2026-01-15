import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:clock_learning/models/level.dart';
import 'package:clock_learning/models/problem.dart';
import 'package:clock_learning/services/problem_generator_service.dart';
import 'package:clock_learning/services/progress_service.dart';
import 'package:clock_learning/services/storage_service.dart';
import 'package:clock_learning/models/time.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('統合テスト: ゲームフロー', () {
    late ProblemGeneratorService problemGenerator;
    late StorageService storageService;
    late ProgressService progressService;
    const MethodChannel channel = MethodChannel('plugins.flutter.io/shared_preferences');

    setUp(() async {
      // SharedPreferencesのMethodChannelをモック
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'getAll') {
          // テスト用の空のデータを返す
          return <String, dynamic>{};
        }
        return null;
      });

      // SharedPreferencesのインスタンスをクリアしてから再初期化
      SharedPreferences.setMockInitialValues({});
      
      problemGenerator = ProblemGeneratorService();
      storageService = await StorageService.create();
      progressService = ProgressService(storageService);
    });

    tearDown(() async {
      // MethodChannelのモックをクリア
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      
      await storageService.clearAllData();
    });

    tearDown(() async {
      await storageService.clearAllData();
    });

    test('レベル選択から問題生成までのフロー', () {
      final problem = problemGenerator.generateProblem(Level.easy);
      expect(problem.level, Level.easy);
      expect(problem.hour >= 1 && problem.hour <= 12, true);
      expect(problem.targetTime.minute, 0);
    });

    test('問題生成から正解判定までのフロー', () {
      final problem = problemGenerator.generateProblem(Level.normal);
      final userAnswer = problem.targetTime;
      final isCorrect = problemGenerator.validateAnswer(
        problem,
        userAnswer.hour,
        userAnswer.minute,
      );
      expect(isCorrect, true);
    });

    test('進捗記録から進捗表示までのフロー', () async {
      // 進捗を記録
      await progressService.recordAnswer(Level.easy, true);
      await progressService.recordAnswer(Level.easy, false);

      // 進捗を取得
      final progress = await progressService.getProgress();
      expect(progress.totalQuestions, 2);
      expect(progress.totalCorrectAnswers, 1);
      expect(progress.accuracyRate, 0.5);
    });

    test('複数レベルの進捗が正しく記録される', () async {
      await progressService.recordAnswer(Level.easy, true);
      await progressService.recordAnswer(Level.normal, true);
      await progressService.recordAnswer(Level.hard, false);

      final progress = await progressService.getProgress();
      expect(progress.totalQuestions, 3);
      expect(progress.totalCorrectAnswers, 2);
      expect(progress.levelProgress[Level.easy]!.totalAttempts, 1);
      expect(progress.levelProgress[Level.normal]!.totalAttempts, 1);
      expect(progress.levelProgress[Level.hard]!.totalAttempts, 1);
    });
  });
}
