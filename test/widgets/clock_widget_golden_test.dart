import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clock_learning/widgets/clock_widget.dart';
import 'package:clock_learning/widgets/clock_controller.dart';
import 'package:clock_learning/models/level.dart';

void main() {
  group('ClockWidget Golden Tests', () {
    testWidgets('かんたんレベル - 12時0分', (WidgetTester tester) async {
      final controller = ClockController();
      controller.initialize(12, 0, Level.easy);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ClockWidget(
                controller: controller,
                level: Level.easy,
                size: 300,
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(ClockWidget),
        matchesGoldenFile('clock_widget_easy_12_00.png'),
      );

      controller.dispose();
    });

    testWidgets('かんたんレベル - 3時0分', (WidgetTester tester) async {
      final controller = ClockController();
      controller.initialize(3, 0, Level.easy);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ClockWidget(
                controller: controller,
                level: Level.easy,
                size: 300,
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(ClockWidget),
        matchesGoldenFile('clock_widget_easy_3_00.png'),
      );

      controller.dispose();
    });

    testWidgets('ふつうレベル - 3時15分', (WidgetTester tester) async {
      final controller = ClockController();
      controller.initialize(3, 15, Level.normal);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ClockWidget(
                controller: controller,
                level: Level.normal,
                size: 300,
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(ClockWidget),
        matchesGoldenFile('clock_widget_normal_3_15.png'),
      );

      controller.dispose();
    });

    testWidgets('ふつうレベル - 6時30分', (WidgetTester tester) async {
      final controller = ClockController();
      controller.initialize(6, 30, Level.normal);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ClockWidget(
                controller: controller,
                level: Level.normal,
                size: 300,
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(ClockWidget),
        matchesGoldenFile('clock_widget_normal_6_30.png'),
      );

      controller.dispose();
    });

    testWidgets('むずかしいレベル - 9時37分（1分刻み目盛り表示）', (WidgetTester tester) async {
      final controller = ClockController();
      controller.initialize(9, 37, Level.hard);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ClockWidget(
                controller: controller,
                level: Level.hard,
                size: 300,
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(ClockWidget),
        matchesGoldenFile('clock_widget_hard_9_37.png'),
      );

      controller.dispose();
    });

    testWidgets('むずかしいレベル - 12時59分', (WidgetTester tester) async {
      final controller = ClockController();
      controller.initialize(12, 59, Level.hard);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ClockWidget(
                controller: controller,
                level: Level.hard,
                size: 300,
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(ClockWidget),
        matchesGoldenFile('clock_widget_hard_12_59.png'),
      );

      controller.dispose();
    });

    testWidgets('分針操作中の視覚的フィードバック（ドラッグ中）', (WidgetTester tester) async {
      final controller = ClockController();
      controller.initialize(3, 15, Level.normal);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ClockWidget(
                controller: controller,
                level: Level.normal,
                size: 300,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // ドラッグ操作をシミュレート
      final clockFinder = find.byType(ClockWidget);
      final center = tester.getCenter(clockFinder);
      final clockSize = tester.getSize(clockFinder);
      
      // タッチ開始（時計の外周付近をタップ）
      final startPoint = Offset(center.dx, center.dy - clockSize.height / 2 * 0.9);
      await tester.tapAt(startPoint);
      await tester.pump();

      // ドラッグ中（分針が青くなる）
      final endPoint = Offset(center.dx + 50, center.dy - 50);
      await tester.dragFrom(startPoint, endPoint - startPoint);
      await tester.pump();

      // ドラッグ状態が反映されるまで待機
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(ClockWidget),
        matchesGoldenFile('clock_widget_dragging.png'),
      );

      controller.dispose();
    });

    testWidgets('異なるサイズでの時計表示 - 小さいサイズ', (WidgetTester tester) async {
      final controller = ClockController();
      controller.initialize(3, 15, Level.normal);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ClockWidget(
                controller: controller,
                level: Level.normal,
                size: 200,
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(ClockWidget),
        matchesGoldenFile('clock_widget_small_size.png'),
      );

      controller.dispose();
    });

    testWidgets('異なるサイズでの時計表示 - 大きいサイズ', (WidgetTester tester) async {
      final controller = ClockController();
      controller.initialize(3, 15, Level.normal);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ClockWidget(
                controller: controller,
                level: Level.normal,
                size: 400,
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(ClockWidget),
        matchesGoldenFile('clock_widget_large_size.png'),
      );

      controller.dispose();
    });
  });
}
