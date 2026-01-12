import 'package:clock_learning/models/level.dart';
import 'package:clock_learning/models/level_progress.dart';
import 'package:clock_learning/models/achievement.dart';

/// 学習進捗データの集約ルート
class ProgressData {
  /// レベル別の進捗
  final Map<Level, LevelProgress> levelProgress;

  /// 総正解数
  final int totalCorrectAnswers;

  /// 総問題数
  final int totalQuestions;

  /// 最終学習日
  final DateTime? lastLearningDate;

  /// 連続学習日数
  final int consecutiveDays;

  /// 達成バッジのリスト
  final List<Achievement> achievements;

  ProgressData({
    required this.levelProgress,
    required this.totalCorrectAnswers,
    required this.totalQuestions,
    this.lastLearningDate,
    required this.consecutiveDays,
    required this.achievements,
  }) {
    if (totalCorrectAnswers < 0 || totalCorrectAnswers > totalQuestions) {
      throw ArgumentError.value(
        totalCorrectAnswers,
        'totalCorrectAnswers',
        'Total correct answers must be between 0 and totalQuestions',
      );
    }
    if (totalQuestions < 0) {
      throw ArgumentError.value(
        totalQuestions,
        'totalQuestions',
        'Total questions must be non-negative',
      );
    }
    if (consecutiveDays < 0) {
      throw ArgumentError.value(
        consecutiveDays,
        'consecutiveDays',
        'Consecutive days must be non-negative',
      );
    }
  }

  /// 正解率を取得（0.0〜1.0）
  double get accuracyRate {
    if (totalQuestions == 0) {
      return 0.0;
    }
    return totalCorrectAnswers / totalQuestions;
  }

  /// 空の進捗データを作成
  factory ProgressData.empty() {
    return ProgressData(
      levelProgress: {
        Level.easy: LevelProgress.empty(),
        Level.normal: LevelProgress.empty(),
        Level.hard: LevelProgress.empty(),
      },
      totalCorrectAnswers: 0,
      totalQuestions: 0,
      lastLearningDate: null,
      consecutiveDays: 0,
      achievements: [],
    );
  }

  /// 進捗データをコピーして更新
  ProgressData copyWith({
    Map<Level, LevelProgress>? levelProgress,
    int? totalCorrectAnswers,
    int? totalQuestions,
    DateTime? lastLearningDate,
    int? consecutiveDays,
    List<Achievement>? achievements,
  }) {
    return ProgressData(
      levelProgress: levelProgress ?? this.levelProgress,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      lastLearningDate: lastLearningDate ?? this.lastLearningDate,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      achievements: achievements ?? this.achievements,
    );
  }

  /// JSONからProgressDataを作成
  factory ProgressData.fromJson(Map<String, dynamic> json) {
    final levelProgressMap = <Level, LevelProgress>{};
    final levelProgressJson = json['levelProgress'] as Map<String, dynamic>;
    for (final entry in levelProgressJson.entries) {
      final level = Level.values.firstWhere(
        (l) => l.name == entry.key,
      );
      levelProgressMap[level] = LevelProgress.fromJson(entry.value);
    }

    final achievementsJson = json['achievements'] as List<dynamic>? ?? [];
    final achievements = achievementsJson
        .map((a) => Achievement.fromJson(a as Map<String, dynamic>))
        .toList();

    return ProgressData(
      levelProgress: levelProgressMap,
      totalCorrectAnswers: json['totalCorrectAnswers'] as int,
      totalQuestions: json['totalQuestions'] as int,
      lastLearningDate: json['lastLearningDate'] != null
          ? DateTime.parse(json['lastLearningDate'] as String)
          : null,
      consecutiveDays: json['consecutiveDays'] as int,
      achievements: achievements,
    );
  }

  /// ProgressDataをJSONに変換
  Map<String, dynamic> toJson() {
    final levelProgressJson = <String, dynamic>{};
    for (final entry in levelProgress.entries) {
      levelProgressJson[entry.key.name] = entry.value.toJson();
    }

    return {
      'levelProgress': levelProgressJson,
      'totalCorrectAnswers': totalCorrectAnswers,
      'totalQuestions': totalQuestions,
      'lastLearningDate': lastLearningDate?.toIso8601String(),
      'consecutiveDays': consecutiveDays,
      'achievements': achievements.map((a) => a.toJson()).toList(),
    };
  }
}
