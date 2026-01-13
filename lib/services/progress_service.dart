import 'package:clock_learning/models/level.dart';
import 'package:clock_learning/models/progress_data.dart';
import 'package:clock_learning/models/level_progress.dart';
import 'package:clock_learning/models/achievement.dart';
import 'package:clock_learning/services/storage_service.dart';

/// 学習進捗の管理と永続化を担当するサービス
class ProgressService {
  final StorageService _storageService;
  ProgressData? _cachedProgressData;

  ProgressService(this._storageService);

  /// 進捗データを記録
  Future<void> recordAnswer(Level level, bool isCorrect) async {
    final progressData = await getProgress();
    
    // レベル別の進捗を更新
    final levelProgress = progressData.levelProgress[level] ??
        LevelProgress.empty();
    
    final updatedLevelProgress = levelProgress.copyWith(
      completedProblems: levelProgress.completedProblems + 1,
      correctAnswers: isCorrect
          ? levelProgress.correctAnswers + 1
          : levelProgress.correctAnswers,
      totalAttempts: levelProgress.totalAttempts + 1,
    );

    // 全体の進捗を更新
    final updatedLevelProgressMap = Map<Level, LevelProgress>.from(
      progressData.levelProgress,
    );
    updatedLevelProgressMap[level] = updatedLevelProgress;

    final updatedProgressData = progressData.copyWith(
      levelProgress: updatedLevelProgressMap,
      totalCorrectAnswers: isCorrect
          ? progressData.totalCorrectAnswers + 1
          : progressData.totalCorrectAnswers,
      totalQuestions: progressData.totalQuestions + 1,
    );

    // 達成バッジのチェック
    final newAchievements = _checkAchievements(updatedProgressData);
    final finalProgressData = updatedProgressData.copyWith(
      achievements: [
        ...updatedProgressData.achievements,
        ...newAchievements,
      ],
    );

    // 保存
    await _storageService.saveProgressData(finalProgressData);
    _cachedProgressData = finalProgressData;
  }

  /// 進捗データを取得
  Future<ProgressData> getProgress() async {
    if (_cachedProgressData != null) {
      return _cachedProgressData!;
    }

    final result = await _storageService.loadProgressData();
    if (result is ProgressLoadSuccess) {
      _cachedProgressData = result.data;
      return result.data;
    }

    // 初回起動またはデータ破損の場合は空の進捗データを返す
    final emptyData = ProgressData.empty();
    _cachedProgressData = emptyData;
    return emptyData;
  }

  /// 達成バッジのリストを取得
  Future<List<Achievement>> getAchievements() async {
    final progressData = await getProgress();
    return progressData.achievements;
  }

  /// 学習日を更新
  Future<void> updateLearningDate() async {
    final progressData = await getProgress();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    DateTime? lastLearningDate = progressData.lastLearningDate;
    if (lastLearningDate != null) {
      final lastDate = DateTime(
        lastLearningDate.year,
        lastLearningDate.month,
        lastLearningDate.day,
      );
      
      // 連続学習日数の計算
      int consecutiveDays = progressData.consecutiveDays;
      final daysDifference = today.difference(lastDate).inDays;
      
      if (daysDifference == 0) {
        // 同じ日なので更新不要
        return;
      } else if (daysDifference == 1) {
        // 連続学習
        consecutiveDays = progressData.consecutiveDays + 1;
      } else {
        // 連続が途切れた
        consecutiveDays = 1;
      }

      final updatedProgressData = progressData.copyWith(
        lastLearningDate: now,
        consecutiveDays: consecutiveDays,
      );
      
      await _storageService.saveProgressData(updatedProgressData);
      _cachedProgressData = updatedProgressData;
    } else {
      // 初回学習
      final updatedProgressData = progressData.copyWith(
        lastLearningDate: now,
        consecutiveDays: 1,
      );
      
      await _storageService.saveProgressData(updatedProgressData);
      _cachedProgressData = updatedProgressData;
    }
  }

  /// 達成バッジをチェック
  List<Achievement> _checkAchievements(ProgressData progressData) {
    final newAchievements = <Achievement>[];
    final existingIds = progressData.achievements.map((a) => a.id).toSet();

    // はじめての正解
    if (progressData.totalCorrectAnswers == 1 &&
        !existingIds.contains('first_correct')) {
      newAchievements.add(Achievement(
        id: 'first_correct',
        name: 'はじめてのせいかい',
        unlockedAt: DateTime.now(),
      ));
    }

    // 10問正解
    if (progressData.totalCorrectAnswers == 10 &&
        !existingIds.contains('ten_correct')) {
      newAchievements.add(Achievement(
        id: 'ten_correct',
        name: '10もんせいかい',
        unlockedAt: DateTime.now(),
      ));
    }

    // 50問正解
    if (progressData.totalCorrectAnswers == 50 &&
        !existingIds.contains('fifty_correct')) {
      newAchievements.add(Achievement(
        id: 'fifty_correct',
        name: '50もんせいかい',
        unlockedAt: DateTime.now(),
      ));
    }

    // 100問正解
    if (progressData.totalCorrectAnswers == 100 &&
        !existingIds.contains('hundred_correct')) {
      newAchievements.add(Achievement(
        id: 'hundred_correct',
        name: '100もんせいかい',
        unlockedAt: DateTime.now(),
      ));
    }

    // 連続3日学習
    if (progressData.consecutiveDays == 3 &&
        !existingIds.contains('three_days')) {
      newAchievements.add(Achievement(
        id: 'three_days',
        name: 'れんぞく3にち',
        unlockedAt: DateTime.now(),
      ));
    }

    // 連続7日学習
    if (progressData.consecutiveDays == 7 &&
        !existingIds.contains('seven_days')) {
      newAchievements.add(Achievement(
        id: 'seven_days',
        name: 'れんぞく7にち',
        unlockedAt: DateTime.now(),
      ));
    }

    return newAchievements;
  }

  /// キャッシュをクリア（テスト用）
  void clearCache() {
    _cachedProgressData = null;
  }
}
