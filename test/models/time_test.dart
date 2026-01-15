import 'package:flutter_test/flutter_test.dart';
import 'package:clock_learning/models/time.dart';

void main() {
  group('Time', () {
    test('正常な時刻を作成できる', () {
      final time = Time(hour: 3, minute: 15);
      expect(time.hour, 3);
      expect(time.minute, 15);
    });

    test('12時0分を作成できる', () {
      final time = Time(hour: 12, minute: 0);
      expect(time.hour, 12);
      expect(time.minute, 0);
    });

    test('1時0分を作成できる', () {
      final time = Time(hour: 1, minute: 0);
      expect(time.hour, 1);
      expect(time.minute, 0);
    });

    test('12時59分を作成できる', () {
      final time = Time(hour: 12, minute: 59);
      expect(time.hour, 12);
      expect(time.minute, 59);
    });

    test('hourが1未満の場合、例外をスローする', () {
      expect(
        () => Time(hour: 0, minute: 0),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('hourが12を超える場合、例外をスローする', () {
      expect(
        () => Time(hour: 13, minute: 0),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('minuteが0未満の場合、例外をスローする', () {
      expect(
        () => Time(hour: 1, minute: -1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('minuteが59を超える場合、例外をスローする', () {
      expect(
        () => Time(hour: 1, minute: 60),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('internalHourは0〜11の範囲を返す', () {
      expect(Time(hour: 1, minute: 0).internalHour, 1);
      expect(Time(hour: 12, minute: 0).internalHour, 0);
      expect(Time(hour: 3, minute: 0).internalHour, 3);
    });

    test('displayStringは分が0の場合「◯時」を返す', () {
      expect(Time(hour: 3, minute: 0).displayString, '3時');
      expect(Time(hour: 12, minute: 0).displayString, '12時');
    });

    test('displayStringは分が0以外の場合「◯時◯分」を返す', () {
      expect(Time(hour: 3, minute: 15).displayString, '3時15分');
      expect(Time(hour: 12, minute: 59).displayString, '12時59分');
    });

    test('hiraganaStringは分が0の場合「◯じ」を返す', () {
      expect(Time(hour: 3, minute: 0).hiraganaString, '3じ');
      expect(Time(hour: 12, minute: 0).hiraganaString, '12じ');
    });

    test('hiraganaStringは分が0以外の場合「◯じ ◯ふん」を返す', () {
      expect(Time(hour: 3, minute: 15).hiraganaString, '3じ 15ふん');
      expect(Time(hour: 12, minute: 59).hiraganaString, '12じ 59ふん');
    });

    test('等価性が正しく判定される', () {
      final time1 = Time(hour: 3, minute: 15);
      final time2 = Time(hour: 3, minute: 15);
      final time3 = Time(hour: 3, minute: 16);

      expect(time1 == time2, true);
      expect(time1 == time3, false);
    });

    test('hashCodeが正しく計算される', () {
      final time1 = Time(hour: 3, minute: 15);
      final time2 = Time(hour: 3, minute: 15);
      final time3 = Time(hour: 3, minute: 16);

      expect(time1.hashCode == time2.hashCode, true);
      expect(time1.hashCode == time3.hashCode, false);
    });
  });
}
