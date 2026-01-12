/// レベル別の進捗を表すクラス
class LevelProgress {
  /// 完了した問題数
  final int completedProblems;

  /// 正解数
  final int correctAnswers;

  /// 総試行回数
  final int totalAttempts;

  LevelProgress({
    required this.completedProblems,
    required this.correctAnswers,
    required this.totalAttempts,
  }) {
    if (completedProblems < 0) {
      throw ArgumentError.value(
        completedProblems,
        'completedProblems',
        'Completed problems must be non-negative',
      );
    }
    if (correctAnswers < 0 || correctAnswers > totalAttempts) {
      throw ArgumentError.value(
        correctAnswers,
        'correctAnswers',
        'Correct answers must be between 0 and totalAttempts',
      );
    }
    if (totalAttempts < 0) {
      throw ArgumentError.value(
        totalAttempts,
        'totalAttempts',
        'Total attempts must be non-negative',
      );
    }
  }

  /// 正解率を取得（0.0〜1.0）
  double get accuracyRate {
    if (totalAttempts == 0) {
      return 0.0;
    }
    return correctAnswers / totalAttempts;
  }

  /// 空の進捗を作成
  factory LevelProgress.empty() {
    return LevelProgress(
      completedProblems: 0,
      correctAnswers: 0,
      totalAttempts: 0,
    );
  }

  /// 進捗をコピーして更新
  LevelProgress copyWith({
    int? completedProblems,
    int? correctAnswers,
    int? totalAttempts,
  }) {
    return LevelProgress(
      completedProblems: completedProblems ?? this.completedProblems,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalAttempts: totalAttempts ?? this.totalAttempts,
    );
  }

  /// JSONからLevelProgressを作成
  factory LevelProgress.fromJson(Map<String, dynamic> json) {
    return LevelProgress(
      completedProblems: json['completedProblems'] as int,
      correctAnswers: json['correctAnswers'] as int,
      totalAttempts: json['totalAttempts'] as int,
    );
  }

  /// LevelProgressをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'completedProblems': completedProblems,
      'correctAnswers': correctAnswers,
      'totalAttempts': totalAttempts,
    };
  }
}
