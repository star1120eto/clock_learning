/// 全バッジ定義
class AchievementDefinition {
  final String id;
  final String name;
  final String description;

  const AchievementDefinition({
    required this.id,
    required this.name,
    required this.description,
  });

  static const List<AchievementDefinition> all = [
    AchievementDefinition(id: 'first_correct', name: 'はじめてのせいかい', description: 'はじめてせいかいした'),
    AchievementDefinition(id: 'easy_master', name: 'かんたんマスター', description: 'かんたんで10もんせいかい'),
    AchievementDefinition(id: 'normal_master', name: 'ふつうマスター', description: 'ふつうで10もんせいかい'),
    AchievementDefinition(id: 'hard_master', name: 'むずかしいマスター', description: 'むずかしいで10もんせいかい'),
    AchievementDefinition(id: 'perfect_session', name: 'パーフェクト', description: '5もん全問せいかい'),
    AchievementDefinition(id: 'streak_3', name: '3にちれんぞく', description: '3にちれんぞくでがくしゅう'),
    AchievementDefinition(id: 'streak_7', name: '7にちれんぞく', description: '7にちれんぞくでがくしゅう'),
    AchievementDefinition(id: 'total_50', name: '50もんたっせい', description: 'ごうけい50もんせいかい'),
  ];
}

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
