import 'dart:math';
import 'package:clock_learning/models/level.dart';
import 'package:clock_learning/models/problem.dart';
import 'package:clock_learning/models/five_minute_interval.dart';

/// 問題生成サービス
class ProblemGeneratorService {
  final Random _random = Random();

  /// レベルに応じた問題を生成
  /// 
  /// [level] 難易度レベル
  /// [recentProblems] 直近の問題リスト（重複チェック用、最大10問）
  Problem generateProblem(Level level, {List<Problem>? recentProblems}) {
    Problem problem;
    int attempts = 0;
    const maxAttempts = 100; // 無限ループ防止

    do {
      switch (level) {
        case Level.easy:
          problem = _generateEasyProblem();
          break;
        case Level.normal:
          problem = _generateNormalProblem();
          break;
        case Level.hard:
          problem = _generateHardProblem();
          break;
      }
      attempts++;
    } while (
      _isDuplicate(problem, recentProblems) && attempts < maxAttempts
    );

    return problem;
  }

  /// かんたんレベルの問題を生成（正時のみ）
  Problem _generateEasyProblem() {
    final hour = _random.nextInt(12) + 1; // 1〜12
    return Problem.easy(hour);
  }

  /// ふつうレベルの問題を生成（5分刻み）
  Problem _generateNormalProblem() {
    final hour = _random.nextInt(12) + 1; // 1〜12
    final minuteIntervals = FiveMinuteInterval.values;
    final minute = minuteIntervals[_random.nextInt(minuteIntervals.length)];
    return Problem.normal(hour, minute);
  }

  /// むずかしいレベルの問題を生成（1分刻み）
  Problem _generateHardProblem() {
    final hour = _random.nextInt(12) + 1; // 1〜12
    final minute = _random.nextInt(60); // 0〜59
    return Problem.hard(hour, minute);
  }

  /// 問題が重複しているかチェック
  bool _isDuplicate(Problem problem, List<Problem>? recentProblems) {
    if (recentProblems == null || recentProblems.isEmpty) {
      return false;
    }

    // 直近10問との重複チェック
    final recent = recentProblems.take(10).toList();
    for (final recentProblem in recent) {
      if (recentProblem.hour == problem.hour &&
          recentProblem.targetTime.minute == problem.targetTime.minute) {
        return true;
      }
    }
    return false;
  }

  /// 正解判定
  /// 
  /// [problem] 問題
  /// [userHour] ユーザーの回答（時、1〜12）
  /// [userMinute] ユーザーの回答（分、0〜59）
  bool validateAnswer(Problem problem, int userHour, int userMinute) {
    final targetTime = problem.targetTime;
    return targetTime.hour == userHour && targetTime.minute == userMinute;
  }
}
