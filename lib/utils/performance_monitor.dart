import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// パフォーマンス監視ユーティリティ
class PerformanceMonitor {
  static const double _targetFrameTime = 16.67; // 60fps = 16.67ms/frame
  static const int _alertThreshold = 3; // 3フレーム連続で超過

  int _consecutiveSlowFrames = 0;
  bool _isMonitoring = false;

  /// パフォーマンス監視を開始
  void startMonitoring() {
    if (_isMonitoring) return;
    _isMonitoring = true;

    SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
    developer.log('Performance monitoring started', name: 'PerformanceMonitor');
  }

  /// パフォーマンス監視を停止
  void stopMonitoring() {
    if (!_isMonitoring) return;
    _isMonitoring = false;

    SchedulerBinding.instance.removeTimingsCallback(_onFrameTimings);
    developer.log('Performance monitoring stopped', name: 'PerformanceMonitor');
  }

  /// フレームタイミングのコールバック
  void _onFrameTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      final frameTime = timing.totalSpan.inMicroseconds / 1000.0; // ms

      if (frameTime > _targetFrameTime) {
        _consecutiveSlowFrames++;
        if (_consecutiveSlowFrames >= _alertThreshold) {
          developer.log(
            'Performance alert: $_consecutiveSlowFrames consecutive slow frames detected. '
            'Frame time: ${frameTime.toStringAsFixed(2)}ms (target: $_targetFrameTime ms)',
            name: 'PerformanceMonitor',
            level: 900, // Warning level
          );
        }
      } else {
        _consecutiveSlowFrames = 0;
      }
    }
  }

  /// メモリ使用量を取得（デバッグモードのみ）
  static void logMemoryUsage() {
    if (kDebugMode) {
      // Flutter DevToolsで確認可能
      developer.log(
        'Memory usage: Check Flutter DevTools Memory tab',
        name: 'PerformanceMonitor',
      );
    }
  }
}
