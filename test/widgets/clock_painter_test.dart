import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:clock_learning/widgets/clock_controller.dart';
import 'package:clock_learning/widgets/clock_painter.dart';
import 'package:clock_learning/models/level.dart';

void main() {
  group('ClockPainter（wrong-answer-clock-display）', () {
    late ClockState state;

    setUp(() {
      final controller = ClockController();
      controller.initialize(3, 15, Level.easy);
      state = controller.getCurrentState();
      controller.dispose();
    });

    test('faceBackgroundGreen が変わると shouldRepaint が true を返す', () {
      final painterWhite = ClockPainter(
        state: state,
        clockRadius: 150,
        level: Level.easy,
        faceBackgroundGreen: false,
      );
      final painterGreen = ClockPainter(
        state: state,
        clockRadius: 150,
        level: Level.easy,
        faceBackgroundGreen: true,
      );
      expect(painterGreen.shouldRepaint(painterWhite), true);
      expect(painterWhite.shouldRepaint(painterGreen), true);
    });

    test('faceBackgroundGreen が同じなら shouldRepaint が false を返す', () {
      final painter1 = ClockPainter(
        state: state,
        clockRadius: 150,
        level: Level.easy,
        faceBackgroundGreen: false,
      );
      final painter2 = ClockPainter(
        state: state,
        clockRadius: 150,
        level: Level.easy,
        faceBackgroundGreen: false,
      );
      expect(painter2.shouldRepaint(painter1), false);
    });

    testWidgets('faceBackgroundGreen true で ClockPainter が描画できる', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              painter: ClockPainter(
                state: state,
                clockRadius: 150,
                level: Level.easy,
                faceBackgroundGreen: true,
              ),
              size: const Size(300, 300),
            ),
          ),
        ),
      );
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
