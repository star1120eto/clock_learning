/// 機能フラグ
///
/// 素材や実装が揃っていない機能を、コードを削除せずに UI から隠すためのフラグ。
library;

/// 効果音機能を UI に露出するかどうか。
///
/// `assets/audio/` に音源ファイル（`correct.ogg` / `incorrect.ogg` など）が
/// 未配置のため、既定では **無効**（＝設定画面に「おとをならす」トグルを出さない）。
///
/// 音が鳴らないのに設定画面にトグルがあると、「機能が動作しない」として
/// App Store の審査で指摘され得る（Guideline 2.1 App Completeness）。
///
/// 一時的に有効化して確認したい場合:
/// ```sh
/// flutter run --dart-define=ENABLE_AUDIO=true
/// ```
///
/// 音源を配置して恒久的に有効化する場合は、既定値を `true` にする:
/// ```dart
/// const bool kAudioFeatureEnabled =
///     bool.fromEnvironment('ENABLE_AUDIO', defaultValue: true);
/// ```
///
/// 関連: https://github.com/star1120eto/clock_learning/issues/46
const bool kAudioFeatureEnabled = bool.fromEnvironment('ENABLE_AUDIO');
