import 'package:clock_learning/models/level.dart';
import 'package:clock_learning/models/time.dart';
import 'package:clock_learning/models/five_minute_interval.dart';

/// 問題を表すsealed class
sealed class Problem {
  /// 時（1〜12）
  final int hour;

  /// 問題文（ひらがな表記）
  final String questionText;

  Problem({
    required this.hour,
    required this.questionText,
  }) {
    if (hour < 1 || hour > 12) {
      throw ArgumentError.value(
        hour,
        'hour',
        'Hour must be between 1 and 12',
      );
    }
  }

  /// かんたんレベルの問題を作成
  /// minuteは常に0
  factory Problem.easy(int hour) {
    return EasyProblem(hour: hour, minute: 0);
  }

  /// ふつうレベルの問題を作成
  /// minuteは5分刻みのみ
  factory Problem.normal(int hour, FiveMinuteInterval minute) {
    return NormalProblem(hour: hour, minute: minute);
  }

  /// むずかしいレベルの問題を作成
  /// minuteは0〜59の任意の値
  factory Problem.hard(int hour, int minute) {
    if (minute < 0 || minute > 59) {
      throw ArgumentError.value(
        minute,
        'minute',
        'Minute must be between 0 and 59',
      );
    }
    return HardProblem(hour: hour, minute: minute);
  }

  /// 目標時間を取得
  Time get targetTime;

  /// レベルを取得
  Level get level;
}

/// かんたんレベルの問題
/// minuteは常に0
class EasyProblem extends Problem {
  final int minute; // 常に0

  EasyProblem({
    required super.hour,
    required this.minute,
  }) : super(
          questionText: _formatQuestion(hour, 0),
        ) {
    if (minute != 0) {
      throw ArgumentError.value(
        minute,
        'minute',
        'EasyProblem minute must be 0',
      );
    }
  }

  @override
  Time get targetTime => Time(hour: hour, minute: 0);

  @override
  Level get level => Level.easy;

  static String _formatQuestion(int hour, int minute) {
    if (minute == 0) {
      return '$hour時をあわせてください';
    }
    return '$hour時$minute分をあわせてください';
  }
}

/// ふつうレベルの問題
/// minuteは5分刻みのみ
class NormalProblem extends Problem {
  final FiveMinuteInterval minute;

  NormalProblem({
    required super.hour,
    required this.minute,
  }) : super(
          questionText: _formatQuestion(hour, minute.value),
        );

  @override
  Time get targetTime => Time(hour: hour, minute: minute.value);

  @override
  Level get level => Level.normal;

  static String _formatQuestion(int hour, int minute) {
    if (minute == 0) {
      return '$hour時をあわせてください';
    }
    return '$hour時$minute分をあわせてください';
  }
}

/// むずかしいレベルの問題
/// minuteは0〜59の任意の値
class HardProblem extends Problem {
  final int minute; // 0〜59

  HardProblem({
    required super.hour,
    required this.minute,
  }) : super(
          questionText: _formatQuestion(hour, minute),
        ) {
    if (minute < 0 || minute > 59) {
      throw ArgumentError.value(
        minute,
        'minute',
        'HardProblem minute must be between 0 and 59',
      );
    }
  }

  @override
  Time get targetTime => Time(hour: hour, minute: minute);

  @override
  Level get level => Level.hard;

  static String _formatQuestion(int hour, int minute) {
    if (minute == 0) {
      return '$hour時をあわせてください';
    }
    return '$hour時$minute分をあわせてください';
  }
}
