import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:clock_learning/models/level.dart';
import 'package:clock_learning/widgets/clock_controller.dart';
import 'package:clock_learning/widgets/clock_widget.dart';

/// 与えられた領域に収まる最大サイズで時計を描画するウィジェット。
///
/// [ClockWidget] はサイズを固定値で受け取るため、縦幅の狭い端末では
/// 画面からはみ出してしまう。このウィジェットを `Expanded` などの中に置くと、
/// 利用できる幅と高さの小さいほうに合わせて時計を自動で縮小・拡大する。
class ResponsiveClock extends StatelessWidget {
  final ClockController controller;
  final Level level;

  /// 時計の最大サイズ。大画面で時計が大きくなりすぎるのを防ぐ。
  final double maxSize;

  /// 時計の最小サイズ。これを下回る領域しかない場合でも、
  /// 操作できる大きさを保つためこのサイズで描画する。
  final double minSize;

  final bool displayCorrectTime;
  final int? correctHour;
  final int? correctMinute;
  final bool faceBackgroundGreen;

  const ResponsiveClock({
    super.key,
    required this.controller,
    required this.level,
    this.maxSize = 300,
    this.minSize = 120,
    this.displayCorrectTime = false,
    this.correctHour,
    this.correctMinute,
    this.faceBackgroundGreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : maxSize;
        final availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : maxSize;
        final available = math.min(availableWidth, availableHeight);
        final size = available.clamp(minSize, maxSize).toDouble();

        return Center(
          child: ClockWidget(
            controller: controller,
            level: level,
            size: size,
            displayCorrectTime: displayCorrectTime,
            correctHour: correctHour,
            correctMinute: correctMinute,
            faceBackgroundGreen: faceBackgroundGreen,
          ),
        );
      },
    );
  }
}
