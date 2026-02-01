import 'package:flutter/material.dart';
import 'package:clock_learning/widgets/clock_controller.dart';
import 'package:clock_learning/widgets/clock_painter.dart';
import 'package:clock_learning/models/level.dart';

/// アナログ時計ウィジェット
class ClockWidget extends StatefulWidget {
  final ClockController controller;
  final double size;
  final Level level;
  /// 不正解表示時は true。正解の時刻を表示し操作を無効にする
  final bool displayCorrectTime;
  /// 正解の時（1〜12）。displayCorrectTime が true のとき使用
  final int? correctHour;
  /// 正解の分（0〜59）。displayCorrectTime が true のとき使用
  final int? correctMinute;
  /// 不正解表示時は true で文字盤を緑に描画する
  final bool faceBackgroundGreen;

  const ClockWidget({
    super.key,
    required this.controller,
    required this.level,
    this.size = 300.0,
    this.displayCorrectTime = false,
    this.correctHour,
    this.correctMinute,
    this.faceBackgroundGreen = false,
  });

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  @override
  void initState() {
    super.initState();
    // ClockControllerの変更を監視
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final showCorrect =
        widget.displayCorrectTime &&
        widget.correctHour != null &&
        widget.correctMinute != null;
    final displayState = showCorrect
        ? widget.controller.getStateForDisplay(
            widget.correctHour!,
            widget.correctMinute!,
          )
        : widget.controller.getCurrentState();

    final content = Container(
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
          state: displayState,
          clockRadius: widget.size / 2,
          level: widget.level,
          faceBackgroundGreen: widget.faceBackgroundGreen,
        ),
      ),
    );

    if (showCorrect) {
      return IgnorePointer(child: content);
    }

    return GestureDetector(
      onPanStart: (details) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox == null) return;

        final localPosition = renderBox.globalToLocal(details.globalPosition);
        widget.controller.onTouchStart(
          localPosition,
          renderBox.size,
        );
      },
      onPanUpdate: (details) {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox == null) return;

        final localPosition = renderBox.globalToLocal(details.globalPosition);
        widget.controller.onDragUpdate(
          localPosition,
          renderBox.size,
        );
      },
      onPanEnd: (_) {
        widget.controller.onTouchEnd();
      },
      child: content,
    );
  }
}
