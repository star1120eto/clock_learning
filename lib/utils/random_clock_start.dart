import 'dart:math';
import 'package:clock_learning/models/level.dart';
import 'package:clock_learning/models/five_minute_interval.dart';

/// レベルに応じた有効範囲内のランダムな時計の開始時刻を返す。
///
/// [level] に応じた有効範囲:
/// - かんたん: 時 1〜12、分 0 のみ
/// - ふつう: 時 1〜12、分 5分刻み（0, 5, …, 55）
/// - むずかしい: 時 1〜12、分 0〜59
///
/// [random] を渡すとテストで再現可能。省略時は [Random()] を使用する。
({int hour, int minute}) getRandomClockStart(Level level, [Random? random]) {
  final r = random ?? Random();
  final hour = 1 + r.nextInt(12);
  final minute = switch (level) {
    Level.easy => 0,
    Level.normal => FiveMinuteInterval.values[r.nextInt(FiveMinuteInterval.values.length)].value,
    Level.hard => r.nextInt(60),
  };
  return (hour: hour, minute: minute);
}
