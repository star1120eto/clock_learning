/// 時間を表す値オブジェクト
/// hour: 1〜12（時計盤表示に合わせた12時間表記）
/// minute: 0〜59
class Time {
  /// 時（1〜12）
  final int hour;

  /// 分（0〜59）
  final int minute;

  /// Time値オブジェクトを作成
  /// 
  /// [hour]は1〜12の範囲内である必要があります
  /// [minute]は0〜59の範囲内である必要があります
  /// 
  /// Throws [ArgumentError] if [hour] or [minute] is out of range
  Time({
    required this.hour,
    required this.minute,
  }) {
    if (hour < 1 || hour > 12) {
      throw ArgumentError.value(
        hour,
        'hour',
        'Hour must be between 1 and 12',
      );
    }
    if (minute < 0 || minute > 59) {
      throw ArgumentError.value(
        minute,
        'minute',
        'Minute must be between 0 and 59',
      );
    }
  }

  /// 内部計算用のhour（0〜11）を取得
  /// 時計計算時に使用
  int get internalHour => hour % 12;

  /// 時間を文字列で取得（数字表記）
  /// 例: "3時15分"
  String get displayString {
    if (minute == 0) {
      return '$hour時';
    }
    return '$hour時$minute分';
  }

  /// 時間をひらがなで取得（時と分は数字、「じ」「ふん」はひらがな）
  /// 例: "3じ 15ふん"
  String get hiraganaString {
    if (minute == 0) {
      return '$hourじ';
    }
    return '$hourじ $minuteふん';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Time && other.hour == hour && other.minute == minute;
  }

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() => displayString;
}
