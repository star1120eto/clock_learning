import 'dart:math';
import 'package:flutter/material.dart';
import 'package:clock_learning/widgets/clock_controller.dart';

/// 時計を描画するCustomPainter
class ClockPainter extends CustomPainter {
  final ClockState state;
  final double clockRadius;

  ClockPainter({
    required this.state,
    required this.clockRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // 時計盤の描画
    _drawClockFace(canvas, center, radius);

    // 数字の描画（1〜12）
    _drawNumbers(canvas, center, radius);

    // 時針の描画
    _drawHourHand(canvas, center, radius);

    // 分針の描画
    _drawMinuteHand(canvas, center, radius);
  }

  /// 時計盤を描画
  void _drawClockFace(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);

    // 時計盤の縁
    final borderPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawCircle(center, radius, borderPaint);
  }

  /// 数字（1〜12）を描画
  void _drawNumbers(Canvas canvas, Offset center, double radius) {
    final textStyle = TextStyle(
      fontSize: radius * 0.15,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );

    for (int i = 1; i <= 12; i++) {
      // 数字の位置を計算（12時を0度として時計回り）
      final angle = (i * 30.0 - 90.0) * (pi / 180); // 12時を上にするため-90度
      final numberRadius = radius * 0.75; // 数字は時計盤の75%の位置
      final x = center.dx + cos(angle) * numberRadius;
      final y = center.dy + sin(angle) * numberRadius;

      final textSpan = TextSpan(
        text: i.toString(),
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
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
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.03 // 時針の太さ
      ..strokeCap = StrokeCap.round;

    final handLength = radius * 0.5; // 時針の長さ
    final angle = state.hourAngle - pi / 2; // 12時を上にするため-90度

    final endX = center.dx + cos(angle) * handLength;
    final endY = center.dy + sin(angle) * handLength;

    canvas.drawLine(center, Offset(endX, endY), paint);
  }

  /// 分針を描画
  void _drawMinuteHand(Canvas canvas, Offset center, double radius) {
    // ドラッグ中は色を変更（視覚的フィードバック）
    final color = state.interactionState == ClockInteractionState.dragging
        ? Colors.blue
        : Colors.black87;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.02 // 分針の太さ（時針より細く）
      ..strokeCap = StrokeCap.round;

    final handLength = radius * 0.7; // 分針の長さ
    final angle = state.minuteAngle - pi / 2; // 12時を上にするため-90度

    final endX = center.dx + cos(angle) * handLength;
    final endY = center.dy + sin(angle) * handLength;

    canvas.drawLine(center, Offset(endX, endY), paint);
  }

  @override
  bool shouldRepaint(ClockPainter oldDelegate) {
    // 角度または操作状態が変更された場合のみ再描画
    return oldDelegate.state.hourAngle != state.hourAngle ||
        oldDelegate.state.minuteAngle != state.minuteAngle ||
        oldDelegate.state.interactionState != state.interactionState;
  }
}
