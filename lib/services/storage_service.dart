import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clock_learning/models/progress_data.dart';

/// データ読み込み結果を表すsealed class
sealed class ProgressLoadResult {
  const ProgressLoadResult();
}

/// 正常に読み込めた場合
class ProgressLoadSuccess extends ProgressLoadResult {
  final ProgressData data;
  const ProgressLoadSuccess(this.data);
}

/// データ破損を検出した場合
class ProgressLoadCorrupted extends ProgressLoadResult {
  final String message; // ひらがな表記
  const ProgressLoadCorrupted(this.message);
}

/// 初回起動の場合
class ProgressLoadFirstLaunch extends ProgressLoadResult {
  const ProgressLoadFirstLaunch();
}

/// ローカルデータの永続化を担当するサービス
class StorageService {
  static const String _keyProgressData = 'progressData';
  static const String _keySchemaVersion = 'schemaVersion';
  static const int _currentSchemaVersion = 1;

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  /// StorageServiceのインスタンスを作成
  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  /// 進捗データを保存
  Future<void> saveProgressData(ProgressData data) async {
    try {
      final jsonData = {
        'schemaVersion': _currentSchemaVersion,
        'progressData': data.toJson(),
      };
      final jsonString = jsonEncode(jsonData);
      await _prefs.setString(_keyProgressData, jsonString);
    } catch (e) {
      throw Exception('Failed to save progress data: $e');
    }
  }

  /// 進捗データを読み込み
  Future<ProgressLoadResult> loadProgressData() async {
    try {
      final jsonString = _prefs.getString(_keyProgressData);
      
      // データが存在しない場合は初回起動
      if (jsonString == null) {
        return const ProgressLoadFirstLaunch();
      }

      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // スキーマバージョンの確認
      final schemaVersion = jsonData['schemaVersion'] as int?;
      if (schemaVersion == null || schemaVersion != _currentSchemaVersion) {
        // スキーマバージョン不一致の場合はデータ破損として扱う
        return const ProgressLoadCorrupted(
          'データのバージョンが一致しません。リセットしますか？',
        );
      }

      // 進捗データの読み込み
      final progressDataJson = jsonData['progressData'] as Map<String, dynamic>;
      final progressData = ProgressData.fromJson(progressDataJson);
      
      return ProgressLoadSuccess(progressData);
    } catch (e) {
      // JSON解析エラーなどはデータ破損として扱う
      return const ProgressLoadCorrupted(
        'データがこわれています。リセットしますか？',
      );
    }
  }

  /// すべてのデータを削除
  Future<void> clearAllData() async {
    await _prefs.remove(_keyProgressData);
    await _prefs.remove(_keySchemaVersion);
  }

  /// 進捗データをJSON文字列としてエクスポート（バックアップ用）
  Future<String?> exportProgressData() async {
    try {
      final result = await loadProgressData();
      if (result is ProgressLoadSuccess) {
        final jsonData = {
          'schemaVersion': _currentSchemaVersion,
          'progressData': result.data.toJson(),
        };
        return jsonEncode(jsonData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// JSON文字列から進捗データをインポート（リストア用）
  Future<bool> importProgressData(String jsonData) async {
    try {
      final jsonMap = jsonDecode(jsonData) as Map<String, dynamic>;
      
      // スキーマバージョンの確認
      final schemaVersion = jsonMap['schemaVersion'] as int?;
      if (schemaVersion == null || schemaVersion != _currentSchemaVersion) {
        return false;
      }

      // 進捗データの読み込みと検証
      final progressDataJson = jsonMap['progressData'] as Map<String, dynamic>;
      final progressData = ProgressData.fromJson(progressDataJson);
      
      // 検証が成功したら保存
      await saveProgressData(progressData);
      return true;
    } catch (e) {
      return false;
    }
  }
}
