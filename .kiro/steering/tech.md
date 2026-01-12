# 技術スタック

## フレームワーク
- **Flutter**: クロスプラットフォーム開発フレームワーク
- **Dart**: 3.10.7以上

## 開発環境
- Flutter SDK
- Android Studio / VS Code
- iOS開発: Xcode（macOS環境）

## 主要パッケージ（現時点）
- `flutter`: SDK
- `cupertino_icons`: ^1.0.8
- `flutter_lints`: ^6.0.0（開発時）

## アーキテクチャ方針
- 状態管理: 未定（Provider, Riverpod, Bloc等から選択）
- UI: Material Design / Cupertino Design
- データ永続化: 未定（SharedPreferences, Hive, SQLite等から選択）

## パフォーマンス要件
- スムーズなアニメーション（60fps）
- 軽量なアプリサイズ
- 低メモリ使用量

## セキュリティ
- 個人情報の最小限の収集
- オフライン動作を基本とする
- 必要に応じてデータ暗号化
