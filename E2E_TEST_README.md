# E2Eテスト実行ガイド

このプロジェクトのE2E（End-to-End）テストの実行方法を説明します。

## 前提条件

- Flutter SDKがインストールされていること
- エミュレータまたは実機が起動していること（Android/iOS）

## E2Eテストの場所

E2Eテストは `integration_test/` ディレクトリに配置されています。

```
integration_test/
  └── app_test.dart  # メインのE2Eテストファイル
```

## 実行方法

### 1. Android エミュレータ/実機で実行

```bash
# エミュレータまたは実機を起動してから
flutter test integration_test/app_test.dart
```

または、より詳細な出力が必要な場合：

```bash
flutter test integration_test/app_test.dart --verbose
```

### 2. iOS シミュレータ/実機で実行

```bash
# iOSシミュレータまたは実機を起動してから
flutter test integration_test/app_test.dart
```

### 3. 特定のプラットフォームを指定して実行

```bash
# Android
flutter test integration_test/app_test.dart -d android

# iOS
flutter test integration_test/app_test.dart -d ios
```

### 4. デバイス一覧の確認

実行可能なデバイスを確認するには：

```bash
flutter devices
```

## テスト内容

現在実装されているE2Eテスト：

1. **ホーム画面からレベル選択、ゲーム開始までのフロー**
   - ホーム画面の表示確認
   - レベル選択画面への遷移
   - ゲーム画面の表示確認

2. **分針操作から正解判定までのインタラクション**
   - 時計の分針をドラッグ操作
   - 回答確定ボタンのタップ
   - 結果メッセージの表示確認

3. **進捗画面でのデータ表示確認**
   - 進捗画面への遷移
   - 進捗データの表示確認

## トラブルシューティング

### エミュレータ/実機が認識されない場合

```bash
# Android
adb devices

# iOS
xcrun simctl list devices
```

### テストがタイムアウトする場合

`pumpAndSettle()` の代わりに、より長いタイムアウトを設定：

```dart
await tester.pumpAndSettle(const Duration(seconds: 5));
```

### ビルドエラーが発生する場合

```bash
# クリーンビルド
flutter clean
flutter pub get
flutter test integration_test/app_test.dart
```

## CI/CDでの実行

CI/CDパイプラインでE2Eテストを実行する場合：

```yaml
# GitHub Actions の例
- name: Run E2E tests
  run: |
    flutter test integration_test/app_test.dart
```

## 参考資料

- [Flutter Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [integration_test パッケージ](https://pub.dev/packages/integration_test)
