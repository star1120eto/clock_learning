import 'dart:math';
import 'package:flutter/material.dart';
import 'package:clock_learning/widgets/clock_controller.dart';
import 'package:clock_learning/models/level.dart';

/// 時計を描画するCustomPainter
class ClockPainter extends CustomPainter {
  final ClockState state;
  final double clockRadius;
  final Level level;
  /// 不正解表示時は true で文字盤を緑に描画する
  final bool faceBackgroundGreen;

  static const List<Color> _numberColors = [
    Colors.red,
    Colors.orange,
    Colors.amber,
    Color(0xFF4CAF50), // green
    Colors.teal,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
    Colors.deepOrange,
    Color(0xFF00BCD4), // cyan
    Color(0xFF8BC34A), // light green
  ];

  ClockPainter({
    required this.state,
    required this.clockRadius,
    required this.level,
    this.faceBackgroundGreen = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // 時計盤の描画
    _drawClockFace(canvas, center, radius);

    // むずかしいモードのときは1分ごとの目盛り線を描画
    if (level == Level.hard) {
      _drawMinuteMarks(canvas, center, radius);
    }

    // 数字の描画（1〜12）
    _drawNumbers(canvas, center, radius);

    // 時針の描画
    _drawHourHand(canvas, center, radius);

    // 分針の描画
    _drawMinuteHand(canvas, center, radius);

    // 中心ドットの描画
    _drawCenterDot(canvas, center, radius);
  }

  /// 1分ごとの目盛り線を描画（むずかしいモードのみ）
  void _drawMinuteMarks(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i < 60; i++) {
      // 各数字の位置（1〜12）の間には5本の線がある
      // 数字の位置は i % 5 == 0 のとき（0, 5, 10, 15, ...）
      // 数字の間は i % 5 != 0 のとき
      if (i % 5 != 0) {
        final angle = (i * 6.0 - 90.0) * (pi / 180); // 12時を上にするため-90度
        final startRadius = radius * 0.85; // 目盛り線の開始位置
        final endRadius = radius * 0.92; // 目盛り線の終了位置

        final startX = center.dx + cos(angle) * startRadius;
        final startY = center.dy + sin(angle) * startRadius;
        final endX = center.dx + cos(angle) * endRadius;
        final endY = center.dy + sin(angle) * endRadius;

        canvas.drawLine(
          Offset(startX, startY),
          Offset(endX, endY),
          paint,
        );
      }
    }
  }

  /// 時計盤を描画
  void _drawClockFace(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = faceBackgroundGreen ? Colors.green : const Color(0xFFFFF9E6)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);

    // 時計盤の縁（レベル別カラー）
    final Color borderColor;
    switch (level) {
      case Level.easy:
        borderColor = Colors.blue;
        break;
      case Level.normal:
        borderColor = Colors.orange;
        break;
      case Level.hard:
        borderColor = Colors.red;
        break;
    }

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;

    canvas.drawCircle(center, radius, borderPaint);
  }

  /// 数字（1〜12）を描画
  void _drawNumbers(Canvas canvas, Offset center, double radius) {
    // TextPainterを再利用してメモリ効率を向上
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 1; i <= 12; i++) {
      // 数字の位置を計算（12時を0度として時計回り）
      final angle = (i * 30.0 - 90.0) * (pi / 180); // 12時を上にするため-90度
      final numberRadius = radius * 0.75; // 数字は時計盤の75%の位置
      final x = center.dx + cos(angle) * numberRadius;
      final y = center.dy + sin(angle) * numberRadius;

      final textStyle = TextStyle(
        fontSize: radius * 0.15,
        fontWeight: FontWeight.bold,
        color: _numberColors[i - 1],
      );

      textPainter.text = TextSpan(
        text: i.toString(),
        style: textStyle,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  /// 時針を描画
  void _drawHourHand(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.indigo
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.05 // 時針の太さ
      ..strokeCap = StrokeCap.round;

    final handLength = radius * 0.5; // 時針の長さ
    final angle = state.hourAngle - pi / 2; // 12時を上にするため-90度

    final endX = center.dx + cos(angle) * handLength;
    final endY = center.dy + sin(angle) * handLength;

    canvas.drawLine(center, Offset(endX, endY), paint);
  }

  /// 分針を描画
  void _drawMinuteHand(Canvas canvas, Offset center, double radius) {
    // ドラッグ中は色と太さを変更（色覚多様性対応：色＋太さ変更の併用）
    final isDragging = state.interactionState == ClockInteractionState.dragging;
    final color = isDragging ? Colors.blue : Colors.red;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.03
      ..strokeCap = StrokeCap.round;

    final handLength = radius * 0.7; // 分針の長さ
    final angle = state.minuteAngle - pi / 2; // 12時を上にするため-90度

    final endX = center.dx + cos(angle) * handLength;
    final endY = center.dy + sin(angle) * handLength;

    canvas.drawLine(center, Offset(endX, endY), paint);
  }

  /// 中心ドットを描画
  void _drawCenterDot(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.04, paint);
  }

  @override
  bool shouldRepaint(ClockPainter oldDelegate) {
    // 角度または操作状態、レベル、文字盤色が変更された場合に再描画
    return oldDelegate.state.hourAngle != state.hourAngle ||
        oldDelegate.state.minuteAngle != state.minuteAngle ||
        oldDelegate.state.interactionState != state.interactionState ||
        oldDelegate.level != level ||
        oldDelegate.faceBackgroundGreen != faceBackgroundGreen;
  }
}
