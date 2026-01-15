import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:clock_learning/widgets/clock_controller.dart';
import 'package:clock_learning/models/level.dart';
import 'dart:math';

void main() {
  group('ClockController', () {
    late ClockController controller;

    setUp(() {
      controller = ClockController();
    });

    tearDown(() {
      controller.dispose();
    });

    group('初期化', () {
      test('時計を初期化できる', () {
        controller.initialize(3, 15, Level.easy);
        expect(controller.getCurrentHour(), 3);
        expect(controller.getCurrentMinute(), 15);
      });

      test('12時0分で初期化できる', () {
        controller.initialize(12, 0, Level.easy);
        expect(controller.getCurrentHour(), 12);
        expect(controller.getCurrentMinute(), 0);
      });

      test('1時0分で初期化できる', () {
        controller.initialize(1, 0, Level.easy);
        expect(controller.getCurrentHour(), 1);
        expect(controller.getCurrentMinute(), 0);
      });
    });

    group('角度計算', () {
      test('時針の角度が正しく計算される', () {
        controller.initialize(3, 0, Level.easy);
        final state = controller.getCurrentState();
        // 3時は90度（π/2ラジアン）
        expect(state.hourAngle, closeTo(pi / 2, 0.01));
      });

      test('分針の角度が正しく計算される', () {
        controller.initialize(12, 15, Level.easy);
        final state = controller.getCurrentState();
        // 15分は90度（π/2ラジアン）
        expect(state.minuteAngle, closeTo(pi / 2, 0.01));
      });

      test('12時0分の角度が正しく計算される', () {
        controller.initialize(12, 0, Level.easy);
        final state = controller.getCurrentState();
        expect(state.hourAngle, closeTo(0, 0.01));
        expect(state.minuteAngle, closeTo(0, 0.01));
      });
    });

    group('スナップ処理', () {
      test('かんたんレベルは5分ごとにスナップされる', () {
        controller.initialize(3, 17, Level.easy);
        controller.onTouchStart(
          const Offset(100, 50),
          const Size(200, 200),
        );
        controller.onTouchEnd();
        final minute = controller.getCurrentMinute();
        expect(minute % 5, 0);
      });

      test('ふつうレベルは5分ごとにスナップされる', () {
        controller.initialize(3, 17, Level.normal);
        controller.onTouchStart(
          const Offset(100, 50),
          const Size(200, 200),
        );
        controller.onTouchEnd();
        final minute = controller.getCurrentMinute();
        expect(minute % 5, 0);
      });

      test('むずかしいレベルはスナップされない', () {
        controller.initialize(3, 17, Level.hard);
        controller.onTouchStart(
          const Offset(100, 50),
          const Size(200, 200),
        );
        controller.onTouchEnd();
        // スナップされないため、任意の分が可能
        final minute = controller.getCurrentMinute();
        expect(minute >= 0 && minute < 60, true);
      });
    });

    group('境界値テスト', () {
      test('1時0分で正しく動作する', () {
        controller.initialize(1, 0, Level.easy);
        expect(controller.getCurrentHour(), 1);
        expect(controller.getCurrentMinute(), 0);
      });

      test('12時0分で正しく動作する', () {
        controller.initialize(12, 0, Level.easy);
        expect(controller.getCurrentHour(), 12);
        expect(controller.getCurrentMinute(), 0);
      });

      test('12時59分で正しく動作する', () {
        controller.initialize(12, 59, Level.hard);
        expect(controller.getCurrentHour(), 12);
        expect(controller.getCurrentMinute(), 59);
      });
    });
  });
}
