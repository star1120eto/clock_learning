import 'dart:math';
import 'package:flutter/material.dart';

enum MascotMood { happy, excited, thinking }

/// ホーム画面に表示するかわいいとけいキャラクター
class ClockMascotWidget extends StatefulWidget {
  final MascotMood mood;
  final double size;

  const ClockMascotWidget({
    super.key,
    this.mood = MascotMood.happy,
    this.size = 110,
  });

  @override
  State<ClockMascotWidget> createState() => _ClockMascotWidgetState();
}

class _ClockMascotWidgetState extends State<ClockMascotWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _bounce = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounce,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _bounce.value),
        child: child,
      ),
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _MascotPainter(widget.mood),
      ),
    );
  }
}

class _MascotPainter extends CustomPainter {
  final MascotMood mood;

  _MascotPainter(this.mood);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.44;

    // 影
    canvas.drawCircle(
      c + const Offset(3, 6),
      r,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // 顔（明るい黄色）
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFFFFF9C4));
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..color = const Color(0xFFFFD600),
    );

    // 時計の目盛り（薄く）
    for (int i = 0; i < 12; i++) {
      final angle = i * 30 * pi / 180;
      final outer = r * 0.86;
      final len = i % 3 == 0 ? r * 0.13 : r * 0.07;
      canvas.drawLine(
        c + Offset(sin(angle) * (outer - len), -cos(angle) * (outer - len)),
        c + Offset(sin(angle) * outer, -cos(angle) * outer),
        Paint()
          ..color = const Color(0xFFBDBDBD)
          ..strokeWidth = i % 3 == 0 ? 2.0 : 1.2
          ..strokeCap = StrokeCap.round,
      );
    }

    // ほっぺ（ピンク）
    final cheekPaint = Paint()..color = Colors.pink.withValues(alpha: 0.28);
    canvas.drawCircle(c + Offset(-r * 0.44, r * 0.14), r * 0.2, cheekPaint);
    canvas.drawCircle(c + Offset(r * 0.44, r * 0.14), r * 0.2, cheekPaint);

    // 目
    _drawEye(canvas, c + Offset(-r * 0.28, -r * 0.1), r * 0.13, mood);
    _drawEye(canvas, c + Offset(r * 0.28, -r * 0.1), r * 0.13, mood);

    // 口
    _drawMouth(canvas, c, r, mood);

    // 時計の針（現在時刻）
    final now = DateTime.now();
    final hourAngle =
        (now.hour % 12 + now.minute / 60.0) * 30 * pi / 180;
    final minuteAngle = now.minute * 6 * pi / 180;

    canvas.drawLine(
      c,
      c + Offset(sin(hourAngle) * r * 0.36, -cos(hourAngle) * r * 0.36),
      Paint()
        ..color = const Color(0xFF5D4037)
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      c,
      c + Offset(sin(minuteAngle) * r * 0.49, -cos(minuteAngle) * r * 0.49),
      Paint()
        ..color = const Color(0xFF795548)
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(c, 4, Paint()..color = const Color(0xFF5D4037));

    // 光沢
    canvas.drawCircle(
      c + Offset(-r * 0.26, -r * 0.32),
      r * 0.09,
      Paint()..color = Colors.white.withValues(alpha: 0.65),
    );
  }

  void _drawEye(
    Canvas canvas,
    Offset center,
    double radius,
    MascotMood mood,
  ) {
    if (mood == MascotMood.excited) {
      // キラキラ目（星形）→ 大きな円＋ハイライト
      canvas.drawCircle(
        center,
        radius * 1.1,
        Paint()..color = const Color(0xFF1A237E),
      );
      // 大きなハイライト
      canvas.drawCircle(
        center + Offset(-radius * 0.2, -radius * 0.3),
        radius * 0.4,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        center + Offset(radius * 0.3, radius * 0.1),
        radius * 0.25,
        Paint()..color = Colors.white,
      );
    } else {
      // 白目
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: radius * 2.2,
          height: radius * 2.4,
        ),
        Paint()..color = Colors.white,
      );
      // 黒目
      canvas.drawCircle(
        center + Offset(radius * 0.1, radius * 0.1),
        radius * 0.78,
        Paint()..color = const Color(0xFF212121),
      );
      // ハイライト
      canvas.drawCircle(
        center + Offset(-radius * 0.15, -radius * 0.28),
        radius * 0.3,
        Paint()..color = Colors.white,
      );
    }
  }

  void _drawMouth(Canvas canvas, Offset c, double r, MascotMood mood) {
    final mouthPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF6D4C41);

    final path = Path();
    final mY = c.dy + r * 0.3;
    final mW = r * 0.35;

    switch (mood) {
      case MascotMood.happy:
        path.moveTo(c.dx - mW, mY);
        path.quadraticBezierTo(c.dx, mY + r * 0.22, c.dx + mW, mY);

      case MascotMood.excited:
        // 大きな笑顔 + 歯
        final smilePath = Path()
          ..moveTo(c.dx - mW, mY)
          ..quadraticBezierTo(c.dx, mY + r * 0.3, c.dx + mW, mY);
        canvas.drawPath(
          smilePath,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.8
            ..strokeCap = StrokeCap.round
            ..color = const Color(0xFF6D4C41),
        );
        // 歯（白い詰め）
        final teethPath = Path()
          ..moveTo(c.dx - mW * 0.7, mY + r * 0.02)
          ..quadraticBezierTo(c.dx, mY + r * 0.22, c.dx + mW * 0.7, mY + r * 0.02)
          ..close();
        canvas.drawPath(teethPath, Paint()..color = Colors.white);
        return;

      case MascotMood.thinking:
        path.moveTo(c.dx - mW * 0.5, mY + r * 0.06);
        path.quadraticBezierTo(
          c.dx,
          mY + r * 0.14,
          c.dx + mW * 0.5,
          mY + r * 0.06,
        );
    }
    canvas.drawPath(path, mouthPaint);
  }

  @override
  bool shouldRepaint(_MascotPainter oldDelegate) =>
      oldDelegate.mood != mood;
}
