# ビルドガイド

clock_learningアプリの各プラットフォーム向けビルド手順をまとめています。

## 前提条件

### 必要な環境

- Flutter SDK 3.38.6以上
- Dart SDK 3.10.7以上

### 環境確認

```bash
# Flutterのバージョン確認
flutter --version

# 環境の診断
flutter doctor -v
```

### 依存関係のインストール

```bash
# パッケージの取得
flutter pub get
```

---

## Web版ビルド

### 開発サーバー起動

```bash
flutter run -d chrome
```

### リリースビルド

```bash
# Webビルド（デフォルト: CanvasKit）
flutter build web --release

# HTML renderer使用（軽量版）
flutter build web --release --web-renderer html

# CanvasKit renderer使用（高品質版）
flutter build web --release --web-renderer canvaskit
```

### 出力先

```
build/web/
```

### デプロイ

GitHub PagesやFirebase Hostingなどにデプロイ可能です。

```bash
# 例: Firebase Hosting
firebase deploy --only hosting
```

---

## Android版ビルド

### 前提条件

- Android Studio
- Android SDK
- Java 17以上

### 開発ビルド

```bash
# デバッグAPK
flutter build apk --debug

# 接続デバイスで実行
flutter run -d android
```

### リリースビルド

```bash
# リリースAPK（すべてのABI）
flutter build apk --release

# ABI別APK（サイズ削減）
flutter build apk --release --split-per-abi

# App Bundle（Google Play推奨）
flutter build appbundle --release
```

### 出力先

```
build/app/outputs/flutter-apk/app-release.apk
build/app/outputs/bundle/release/app-release.aab
```

### 署名設定

リリースビルドには署名が必要です。`android/key.properties`を作成：

```properties
storePassword=<password>
keyPassword=<password>
keyAlias=<alias>
storeFile=<path-to-keystore>
```

---

## iOS版ビルド

### 前提条件

- macOS
- Xcode 15以上
- Apple Developer Account（リリース用）

### 開発ビルド

```bash
# シミュレーターで実行
flutter run -d ios

# 特定のシミュレーター指定
flutter run -d "iPhone 15 Pro"
```

### リリースビルド

```bash
# iOSビルド
flutter build ios --release

# IPA作成（Ad-hoc/App Store）
flutter build ipa --release
```

### 出力先

```
build/ios/ipa/clock_learning.ipa
```

### CocoaPods更新

```bash
cd ios
pod install --repo-update
cd ..
```

### 証明書とProvisioning Profile

Xcodeで以下を設定：
1. Signing & Capabilities
2. Team選択
3. Bundle Identifier設定

---

## macOS版ビルド

### 前提条件

- macOS
- Xcode 15以上

### 開発ビルド

```bash
flutter run -d macos
```

### リリースビルド

```bash
flutter build macos --release
```

### 出力先

```
build/macos/Build/Products/Release/clock_learning.app
```

---

## Linux版ビルド

### 前提条件

```bash
# Ubuntu/Debian
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
```

### 開発ビルド

```bash
flutter run -d linux
```

### リリースビルド

```bash
flutter build linux --release
```

### 出力先

```
build/linux/x64/release/bundle/
```

---

## Windows版ビルド

### 前提条件

- Windows 10/11
- Visual Studio 2022（C++デスクトップ開発ワークロード）

### 開発ビルド

```bash
flutter run -d windows
```

### リリースビルド

```bash
flutter build windows --release
```

### 出力先

```
build/windows/x64/runner/Release/
```

---

## ビルドオプション

### 共通オプション

| オプション | 説明 |
|-----------|------|
| `--release` | リリースビルド |
| `--debug` | デバッグビルド |
| `--profile` | プロファイルビルド |
| `--build-name=X.Y.Z` | バージョン名指定 |
| `--build-number=N` | ビルド番号指定 |
| `--dart-define=KEY=VALUE` | 環境変数の注入 |
| `--obfuscate` | コード難読化 |
| `--split-debug-info=<dir>` | デバッグ情報の分離 |

### 例: バージョン指定ビルド

```bash
flutter build apk --release --build-name=1.2.0 --build-number=12
```

### 例: 環境変数の注入

```bash
flutter build web --release --dart-define=ENV=production
```

---

## クリーンビルド

ビルドに問題がある場合：

```bash
# キャッシュクリア
flutter clean

# パッケージ再取得
flutter pub get

# 再ビルド
flutter build <platform> --release
```

---

## CI/CD

### GitHub Actions例

```yaml
name: Build

on:
  push:
    branches: [main]

jobs:
  build-web:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.38.6'
      - run: flutter pub get
      - run: flutter build web --release
```

---

## トラブルシューティング

### よくある問題

| 問題 | 解決策 |
|-----|--------|
| `pub get`失敗 | `flutter pub cache repair` |
| iOSビルド失敗 | `cd ios && pod install --repo-update` |
| Gradle失敗 | `cd android && ./gradlew clean` |
| 依存関係の競合 | `flutter pub upgrade --major-versions` |

### ログの確認

```bash
# 詳細ログ付きビルド
flutter build <platform> --release -v
```

---

## 参考リンク

- [Flutter公式ドキュメント](https://docs.flutter.dev/)
- [Android App Bundleガイド](https://developer.android.com/guide/app-bundle)
- [App Store Connect](https://appstoreconnect.apple.com/)
