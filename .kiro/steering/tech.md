# 技術スタック

## フレームワーク
- **Flutter**: クロスプラットフォーム開発フレームワーク
- **Dart**: 3.10.7以上

## 開発環境
- Flutter SDK
- Android Studio / VS Code
- iOS開発: Xcode（macOS環境）

## 主要パッケージ
- `flutter`: SDK
- `cupertino_icons`: ^1.0.8
- `provider`: ^6.1.1（状態管理）
- `shared_preferences`: ^2.2.2（データ永続化）
- `audioplayers`: ^5.2.1（音声再生）
- `lottie`: ^3.3.2（アニメーション）
- `flutter_lints`: ^6.0.0（開発時）
- `integration_test`: SDK（E2Eテスト）

## アーキテクチャ方針
- **状態管理**: Provider（軽量で学習曲線が緩やか）
- **UI**: Material Design 3
- **データ永続化**: SharedPreferences（シンプルなKey-Valueストアで十分）
- **アーキテクチャパターン**: レイヤードアーキテクチャ
  - UI層: `screens/`, `widgets/`
  - サービス層: `services/`
  - データ層: `models/`, `services/storage_service.dart`
  - ユーティリティ層: `utils/`

## パフォーマンス要件（実装済み）
- **アニメーション**: 60fps維持（`PerformanceMonitor`で監視）
- **メモリ使用量**: 目標50MB以下（監視機能実装済み）
- **起動時間**: 3秒以内に初期画面表示
- **最適化**: TextPainterキャッシュ、ChangeNotifierによる効率的な状態更新

## セキュリティ
- 個人情報の最小限の収集
- オフライン動作を基本とする
- 必要に応じてデータ暗号化
