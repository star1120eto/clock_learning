import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// まいにちチャレンジの完了状態を管理するサービス
class DailyChallengeService extends ChangeNotifier {
  static const String _kDateKey = 'daily_challenge_date';

  bool _completedToday = false;

  bool get completedToday => _completedToday;

  DailyChallengeService() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kDateKey);
    _completedToday = saved == _todayString();
    notifyListeners();
  }

  /// 本日のチャレンジを完了とマークする
  Future<void> markCompleted() async {
    if (_completedToday) return;
    _completedToday = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDateKey, _todayString());
    notifyListeners();
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
