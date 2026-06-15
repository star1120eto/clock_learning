import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// シールの収集状態を管理するサービス
class StickerService extends ChangeNotifier {
  static const String _kTotalKey = 'total_stickers';

  int _total = 0;

  int get total => _total;

  StickerService() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _total = prefs.getInt(_kTotalKey) ?? 0;
    notifyListeners();
  }

  /// シールを n 枚追加する
  Future<void> addStickers(int count) async {
    if (count <= 0) return;
    _total += count;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTotalKey, _total);
    notifyListeners();
  }

  /// デバッグ用：シールをリセット
  Future<void> debugReset() async {
    if (kDebugMode) {
      _total = 0;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kTotalKey);
      notifyListeners();
    }
  }
}
