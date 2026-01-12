/// 5分刻みの分を表すenum
enum FiveMinuteInterval {
  zero(0),
  five(5),
  ten(10),
  fifteen(15),
  twenty(20),
  twentyFive(25),
  thirty(30),
  thirtyFive(35),
  forty(40),
  fortyFive(45),
  fifty(50),
  fiftyFive(55);

  final int value;
  const FiveMinuteInterval(this.value);

  /// 値からFiveMinuteIntervalを取得
  static FiveMinuteInterval? fromValue(int value) {
    for (final interval in FiveMinuteInterval.values) {
      if (interval.value == value) {
        return interval;
      }
    }
    return null;
  }
}
