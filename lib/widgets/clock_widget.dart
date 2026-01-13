import 'package:flutter/material.dart';
import 'package:clock_learning/widgets/clock_controller.dart';
import 'package:clock_learning/widgets/clock_painter.dart';
import 'package:clock_learning/models/level.dart';

/// アナログ時計ウィジェット
class ClockWidget extends StatefulWidget {
  final ClockController controller;
  final double size;
  final Level level;

  const ClockWidget({
    super.key,
    required this.controller,
    required this.level,
    this.size = 300.0,
  });

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox == null) return;

        final localPosition = renderBox.globalToLocal(details.globalPosition);
        widget.controller.onTouchStart(
          localPosition,
          renderBox.size,
        );
        if (mounted) setState(() {});
      },
      onPanUpdate: (details) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox == null) return;

        final localPosition = renderBox.globalToLocal(details.globalPosition);
        widget.controller.onDragUpdate(
          localPosition,
          renderBox.size,
        );
        if (mounted) setState(() {});
      },
      onPanEnd: (_) {
        widget.controller.onTouchEnd();
        if (mounted) setState(() {});
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: CustomPaint(
          painter: ClockPainter(
            state: widget.controller.getCurrentState(),
            clockRadius: widget.size / 2,
            level: widget.level,
          ),
        ),
      ),
    );
  }
}
