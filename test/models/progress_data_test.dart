import 'package:flutter_test/flutter_test.dart';
import 'package:clock_learning/models/progress_data.dart';
import 'package:clock_learning/models/level.dart';
import 'package:clock_learning/models/level_progress.dart';
import 'package:clock_learning/models/achievement.dart';

void main() {
  group('ProgressData', () {
    test('空の進捗データを作成できる', () {
      final progressData = ProgressData.empty();
      expect(progressData.totalCorrectAnswers, 0);
      expect(progressData.totalQuestions, 0);
      expect(progressData.levelProgress.length, 3);
      expect(progressData.achievements.isEmpty, true);
    });

    test('JSONシリアライゼーションが正しく動作する', () {
      final progressData = ProgressData.empty();
      final json = progressData.toJson();
      final restored = ProgressData.fromJson(json);

      expect(restored.totalCorrectAnswers, progressData.totalCorrectAnswers);
      expect(restored.totalQuestions, progressData.totalQuestions);
      expect(restored.levelProgress.length, progressData.levelProgress.length);
    });

    test('copyWithが正しく動作する', () {
      final original = ProgressData.empty();
      final updated = original.copyWith(
        totalCorrectAnswers: 10,
        totalQuestions: 20,
      );

      expect(updated.totalCorrectAnswers, 10);
      expect(updated.totalQuestions, 20);
      expect(original.totalCorrectAnswers, 0);
      expect(original.totalQuestions, 0);
    });

    test('レベル別進捗が正しく管理される', () {
      final progressData = ProgressData.empty();
      final easyProgress = progressData.levelProgress[Level.easy];
      expect(easyProgress, isNotNull);
      expect(easyProgress!.correctAnswers, 0);
      expect(easyProgress.totalAttempts, 0);
    });
  });

  group('LevelProgress', () {
    test('空のレベル進捗を作成できる', () {
      final levelProgress = LevelProgress.empty();
      expect(levelProgress.correctAnswers, 0);
      expect(levelProgress.totalAttempts, 0);
      expect(levelProgress.accuracyRate, 0.0);
    });

    test('正解率が正しく計算される', () {
      final levelProgress = LevelProgress(
        completedProblems: 10,
        correctAnswers: 8,
        totalAttempts: 10,
      );
      expect(levelProgress.accuracyRate, 0.8);
    });

    test('問題数が0の場合、正解率は0.0', () {
      final levelProgress = LevelProgress.empty();
      expect(levelProgress.accuracyRate, 0.0);
      expect(levelProgress.totalAttempts, 0);
    });

    test('JSONシリアライゼーションが正しく動作する', () {
      final levelProgress = LevelProgress(
        completedProblems: 10,
        correctAnswers: 5,
        totalAttempts: 10,
      );
      final json = levelProgress.toJson();
      final restored = LevelProgress.fromJson(json);

      expect(restored.correctAnswers, levelProgress.correctAnswers);
      expect(restored.totalAttempts, levelProgress.totalAttempts);
    });
  });

  group('Achievement', () {
    test('達成バッジを作成できる', () {
      final achievement = Achievement(
        id: 'first_correct',
        name: 'はじめてのせいかい',
        unlockedAt: DateTime(2024, 1, 1),
      );
      expect(achievement.id, 'first_correct');
      expect(achievement.name, 'はじめてのせいかい');
    });

    test('JSONシリアライゼーションが正しく動作する', () {
      final achievement = Achievement(
        id: 'first_correct',
        name: 'はじめてのせいかい',
        unlockedAt: DateTime(2024, 1, 1),
      );
      final json = achievement.toJson();
      final restored = Achievement.fromJson(json);

      expect(restored.id, achievement.id);
      expect(restored.name, achievement.name);
    });
  });
}
