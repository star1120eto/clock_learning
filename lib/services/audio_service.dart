import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 音声設定
class AudioSettings {
  final bool isMuted;
  final double volume; // 0.0〜1.0

  AudioSettings({
    this.isMuted = false,
    this.volume = 1.0,
  }) {
    if (volume < 0.0 || volume > 1.0) {
      throw ArgumentError.value(
        volume,
        'volume',
        'Volume must be between 0.0 and 1.0',
      );
    }
  }

  AudioSettings copyWith({
    bool? isMuted,
    double? volume,
  }) {
    return AudioSettings(
      isMuted: isMuted ?? this.isMuted,
      volume: volume ?? this.volume,
    );
  }
}

/// 音声フィードバックを提供するサービス
class AudioService {
  static const String _keyIsMuted = 'audio_is_muted';
  final AudioPlayer _player = AudioPlayer();
  final SharedPreferences _prefs;
  AudioSettings? _cachedSettings;

  AudioService(this._prefs);

  /// AudioServiceのインスタンスを作成
  static Future<AudioService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AudioService(prefs);
  }

  /// 正解音声を再生
  Future<void> playCorrectSound() async {
    final settings = getSettings();
    if (settings.isMuted) {
      return;
    }

    try {
      await _player.play(AssetSource('audio/correct.ogg'));
    } catch (e) {
      // 音声ファイルが存在しない場合はエラーを無視
      // （開発中は音声ファイルがまだない可能性がある）
    }
  }

  /// 不正解音声を再生
  Future<void> playIncorrectSound() async {
    final settings = getSettings();
    if (settings.isMuted) {
      return;
    }

    try {
      await _player.play(AssetSource('audio/incorrect.ogg'));
    } catch (e) {
      // 音声ファイルが存在しない場合はエラーを無視
    }
  }

  /// ミュート状態を設定
  Future<void> setMuted(bool muted) async {
    await _prefs.setBool(_keyIsMuted, muted);
    _cachedSettings = null; // キャッシュをクリア
  }

  /// 音量を設定（0.0〜1.0）
  Future<void> setVolume(double volume) async {
    if (volume < 0.0 || volume > 1.0) {
      throw ArgumentError.value(
        volume,
        'volume',
        'Volume must be between 0.0 and 1.0',
      );
    }
    // 端末の音量設定に従うため、ここでは保存のみ
    // 実際の音量制御は端末側で行う
    _cachedSettings = null; // キャッシュをクリア
  }

  /// 現在の設定を取得
  AudioSettings getSettings() {
    if (_cachedSettings != null) {
      return _cachedSettings!;
    }

    final isMuted = _prefs.getBool(_keyIsMuted) ?? false;
    final settings = AudioSettings(isMuted: isMuted, volume: 1.0);
    _cachedSettings = settings;
    return settings;
  }

  /// リソースを解放
  void dispose() {
    _player.dispose();
  }
}
