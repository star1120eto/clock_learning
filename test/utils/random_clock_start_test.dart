import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:clock_learning/models/level.dart';
import 'package:clock_learning/models/five_minute_interval.dart';
import 'package:clock_learning/utils/random_clock_start.dart';

void main() {
  group('getRandomClockStart', () {
    group('有効範囲', () {
      test('かんたんレベルでは時が1〜12・分が0のみ', () {
        final random = Random(42);
        for (var i = 0; i < 50; i++) {
          final (:hour, :minute) = getRandomClockStart(Level.easy, random);
          expect(hour, inInclusiveRange(1, 12));
          expect(minute, 0);
        }
      });

      test('ふつうレベルでは時が1〜12・分が5分刻み', () {
        final validMinutes = FiveMinuteInterval.values.map((e) => e.value).toSet();
        final random = Random(123);
        for (var i = 0; i < 50; i++) {
          final (:hour, :minute) = getRandomClockStart(Level.normal, random);
          expect(hour, inInclusiveRange(1, 12));
          expect(validMinutes.contains(minute), isTrue);
        }
      });

      test('むずかしいレベルでは時が1〜12・分が0〜59', () {
        final random = Random(999);
        for (var i = 0; i < 50; i++) {
          final (:hour, :minute) = getRandomClockStart(Level.hard, random);
          expect(hour, inInclusiveRange(1, 12));
          expect(minute, inInclusiveRange(0, 59));
        }
      });
    });

    group('再現性', () {
      test('同じRandomを渡すと同じ結果になる', () {
        final random1 = Random(1);
        final random2 = Random(1);
        final result1 = getRandomClockStart(Level.normal, random1);
        final result2 = getRandomClockStart(Level.normal, random2);
        expect(result1.hour, result2.hour);
        expect(result1.minute, result2.minute);
      });

      test('乱数を渡さない場合も呼び出せる', () {
        final (:hour, :minute) = getRandomClockStart(Level.easy);
        expect(hour, inInclusiveRange(1, 12));
        expect(minute, 0);
      });
    });
  });
}
