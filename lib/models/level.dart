/// 学習レベルを表すenum
enum Level {
  /// かんたん：正時（◯時）をあわせる
  easy,

  /// ふつう：◯時◯分をあわせる（分は5分刻み）
  normal,

  /// むずかしい：◯時◯分をあわせる（分は1分刻み）
  hard;

  /// レベル名をひらがなで取得
  String get displayName {
    switch (this) {
      case Level.easy:
        return 'かんたん';
      case Level.normal:
        return 'ふつう';
      case Level.hard:
        return 'むずかしい';
    }
  }
}
