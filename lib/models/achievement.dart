/// 達成バッジを表すクラス
class Achievement {
  /// バッジID
  final String id;

  /// バッジ名（ひらがな表記）
  final String name;

  /// 獲得日時
  final DateTime unlockedAt;

  Achievement({
    required this.id,
    required this.name,
    required this.unlockedAt,
  });

  /// JSONからAchievementを作成
  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      unlockedAt: DateTime.parse(json['unlockedAt'] as String),
    );
  }

  /// AchievementをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unlockedAt': unlockedAt.toIso8601String(),
    };
  }
}
