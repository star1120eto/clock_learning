# E2Eテスト実行ガイド

## 実行方法のまとめ

### 1. エミュレータ/実機の起動

#### Androidエミュレータを起動

```bash
# 利用可能なエミュレータを確認
flutter emulators

# エミュレータを起動（例: Pixel_9）
flutter emulators --launch Pixel_9

# エミュレータが起動するまで待つ（約30秒）
# デバイスが認識されているか確認
flutter devices
```

#### iOSシミュレータを起動（Macのみ）

```bash
# シミュレータを起動
open -a Simulator

# または
flutter emulators --launch apple_ios_simulator
```

### 2. E2Eテストの実行

#### 基本的な実行

```bash
# デバイスを自動検出して実行
flutter test integration_test/app_test.dart
```

#### デバイスを指定して実行

```bash
# Android
flutter test integration_test/app_test.dart -d android
# または
flutter test integration_test/app_test.dart -d emulator-5554

# iOS
flutter test integration_test/app_test.dart -d ios
```

#### 詳細な出力で実行

```bash
flutter test integration_test/app_test.dart --verbose
```

### 3. 実行時間について

E2Eテストの初回実行時は、以下の処理に時間がかかります：
- APK/IPAのビルド（約1-2分）
- エミュレータ/実機へのインストール（約30秒）
- テストの実行（約1-2分）

**合計で約3-5分程度かかります。**

2回目以降は、ビルド済みのAPK/IPAがある場合はより高速に実行されます。

### 4. トラブルシューティング

#### デバイスが認識されない場合

```bash
# デバイス一覧を確認
flutter devices

# Androidデバイスの確認
adb devices

# iOSデバイスの確認
xcrun simctl list devices
```

#### テストがタイムアウトする場合

```bash
# タイムアウト時間を延長（デフォルトは30秒）
flutter test integration_test/app_test.dart --device-timeout 60
```

#### ビルドエラーが発生する場合

```bash
# クリーンビルド
flutter clean
flutter pub get
flutter test integration_test/app_test.dart
```

### 5. 現在のテスト内容

実装されているE2Eテスト：

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

### 6. 注意事項

- E2Eテストは実機またはエミュレータ上で実行する必要があります
- テスト実行中はアプリが自動的に起動・操作されます
- テスト完了後、アプリは自動的に終了します
- エミュレータの起動には時間がかかります（初回は特に長い）

### 7. 開発中の推奨事項

開発中は、統合テスト（`test/integration/game_flow_test.dart`）を使用することを推奨します：

```bash
# 統合テストはデバイス不要で高速に実行可能
flutter test test/integration/game_flow_test.dart
```

E2Eテストは、リリース前の最終確認や、実際のデバイスでの動作確認に使用することを推奨します。
