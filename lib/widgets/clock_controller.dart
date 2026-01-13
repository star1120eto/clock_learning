import 'dart:math';
import 'package:flutter/material.dart';
import 'package:clock_learning/models/level.dart';
import 'package:clock_learning/models/five_minute_interval.dart';

/// 時計の操作状態
enum ClockInteractionState {
  /// 待機中
  idle,

  /// ドラッグ中
  dragging,

  /// スナップアニメーション中
  snapping,

  /// 正解/不正解アニメーション中
  animatingResult,
}

/// 時計の状態
class ClockState {
  /// 時（1〜12）
  final int hour;

  /// 分（0〜59）
  final int minute;

  /// 時針の角度（ラジアン、12時を0として時計回り）
  final double hourAngle;

  /// 分針の角度（ラジアン、12時を0として時計回り）
  final double minuteAngle;

  /// 操作状態
  final ClockInteractionState interactionState;

  ClockState({
    required this.hour,
    required this.minute,
    required this.hourAngle,
    required this.minuteAngle,
    required this.interactionState,
  });

  ClockState copyWith({
    int? hour,
    int? minute,
    double? hourAngle,
    double? minuteAngle,
    ClockInteractionState? interactionState,
  }) {
    return ClockState(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      hourAngle: hourAngle ?? this.hourAngle,
      minuteAngle: minuteAngle ?? this.minuteAngle,
      interactionState: interactionState ?? this.interactionState,
    );
  }
}

/// 時計の操作ロジックを担当するコントローラー
class ClockController extends ChangeNotifier {
  ClockState _state = ClockState(
    hour: 12,
    minute: 0,
    hourAngle: 0,
    minuteAngle: 0,
    interactionState: ClockInteractionState.idle,
  );

  Level _level = Level.easy;
  bool _isDragging = false;

  /// 時計を初期化
  void initialize(int hour, int minute, Level level) {
    _level = level;
    _updateState(hour, minute);
    notifyListeners();
  }

  /// タッチ開始時の処理
  void onTouchStart(Offset position, Size clockSize) {
    if (_state.interactionState == ClockInteractionState.animatingResult) {
      // アニメーション中は操作無効
      return;
    }

    if (!_isValidTouchPosition(position, clockSize)) {
      return;
    }

    _isDragging = true;
    _updateMinuteAngleFromPosition(position, clockSize);
    notifyListeners();
  }

  /// ドラッグ更新時の処理
  void onDragUpdate(Offset position, Size clockSize) {
    if (!_isDragging) {
      return;
    }

    _updateMinuteAngleFromPosition(position, clockSize);
    notifyListeners();
  }

  /// タッチ終了時の処理
  void onTouchEnd() {
    if (!_isDragging) {
      return;
    }

    _isDragging = false;

    // スナップ処理
    if (_level == Level.easy || _level == Level.normal) {
      // かんたんモードとふつうモードは5分ごとにスナップ
      _snapToFiveMinuteInterval();
    }
    // むずかしいレベルはスナップなし

    _state = _state.copyWith(
      interactionState: ClockInteractionState.idle,
    );
    notifyListeners();
  }

  /// 現在の状態を取得
  ClockState getCurrentState() => _state;

  /// 現在の時を取得（1〜12）
  int getCurrentHour() => _state.hour;

  /// 現在の分を取得（0〜59）
  int getCurrentMinute() => _state.minute;

  /// 状態を更新
  void _updateState(int hour, int minute) {
    final hourAngle = _calculateHourAngle(hour, minute);
    final minuteAngle = _calculateMinuteAngle(minute);

    _state = _state.copyWith(
      hour: hour,
      minute: minute,
      hourAngle: hourAngle,
      minuteAngle: minuteAngle,
      interactionState: _isDragging
          ? ClockInteractionState.dragging
          : ClockInteractionState.idle,
    );
  }

  /// 時針の角度を計算
  /// hour: 1〜12, minute: 0〜59
  /// 12時を0度として時計回りに計算
  double _calculateHourAngle(int hour, int minute) {
    final hourBase = (hour % 12) * 30.0; // 1時間 = 30度
    final minuteOffset = minute * 0.5; // 1分 = 0.5度
    return (hourBase + minuteOffset) * (pi / 180); // ラジアンに変換
  }

  /// 分針の角度を計算
  /// minute: 0〜59
  /// 12時を0度として時計回りに計算
  double _calculateMinuteAngle(int minute) {
    return minute * 6.0 * (pi / 180); // 1分 = 6度
  }

  /// タッチ位置から分針角度を更新
  void _updateMinuteAngleFromPosition(Offset position, Size clockSize) {
    final center = Offset(clockSize.width / 2, clockSize.height / 2);
    
    // 画面外ドラッグの無効化：時計盤の範囲内に制限
    final radius = min(clockSize.width, clockSize.height) / 2;
    final distance = (position - center).distance;
    
    // 時計盤の範囲外の場合は最後の有効な位置を維持
    if (distance > radius) {
      // 時計盤の外周に制限
      final angle = atan2(position.dy - center.dy, position.dx - center.dx);
      final clampedPosition = Offset(
        center.dx + cos(angle) * radius,
        center.dy + sin(angle) * radius,
      );
      return _updateMinuteAngleFromPosition(clampedPosition, clockSize);
    }
    
    final delta = position - center;
    
    // 角度を計算（-π/2を加えて12時を0度にする）
    double angle = atan2(delta.dy, delta.dx) + pi / 2;
    
    // 0〜2πの範囲に正規化
    if (angle < 0) {
      angle += 2 * pi;
    }

    // 角度から分を計算
    final minute = (angle / (2 * pi) * 60).round() % 60;
    
    // レベルに応じたスナップ
    int snappedMinute = minute;
    if (_level == Level.easy || _level == Level.normal) {
      // かんたんモードとふつうモードは5分ごとにスナップ
      snappedMinute = _snapToFiveMinute(minute);
    }
    // むずかしいレベルはドラッグ中は自由に動かせる

    // 時を計算（分針が1周したら時を進める）
    int hour = _state.hour;
    if (snappedMinute < _state.minute - 30) {
      // 分針が大きく戻った場合は時を進める
      hour = (hour % 12) + 1;
    } else if (snappedMinute > _state.minute + 30) {
      // 分針が大きく進んだ場合は時を戻す
      hour = hour == 1 ? 12 : hour - 1;
    }

    _updateState(hour, snappedMinute);
  }

  /// 5分刻みにスナップ
  int _snapToFiveMinute(int minute) {
    final intervals = FiveMinuteInterval.values;
    int closestMinute = intervals[0].value;
    int minDiff = (minute - closestMinute).abs();

    for (final interval in intervals) {
      final diff = (minute - interval.value).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closestMinute = interval.value;
      }
    }

    return closestMinute;
  }

  /// 5分刻みにスナップ（かんたんレベル・ふつうレベル）
  void _snapToFiveMinuteInterval() {
    final snappedMinute = _snapToFiveMinute(_state.minute);
    _updateState(_state.hour, snappedMinute);
    notifyListeners();
  }

  /// 有効なタッチ位置か判定
  bool _isValidTouchPosition(Offset position, Size clockSize) {
    final center = Offset(clockSize.width / 2, clockSize.height / 2);
    final radius = min(clockSize.width, clockSize.height) / 2;
    
    // 中心からの距離
    final distance = (position - center).distance;
    
    // 中心から半径の20%以内は無効
    if (distance < radius * 0.2) {
      return false;
    }

    // 時計盤外周（半径の80%〜100%）は有効
    if (distance >= radius * 0.8 && distance <= radius) {
      return true;
    }

    // 分針領域の判定（簡易版：時計盤外周の範囲内であれば有効）
    return distance <= radius;
  }
}
