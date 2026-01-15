# E2Eテスト実行ガイド

## 現在の状況

Androidエミュレータまたは実機が接続されていないため、E2Eテストを実行できません。

## 解決方法

### 方法1: Androidエミュレータを起動する

#### 1. 利用可能なエミュレータを確認

```bash
flutter emulators
```

#### 2. エミュレータを起動

```bash
# エミュレータ名を指定して起動
flutter emulators --launch <エミュレータ名>

# 例: Pixel_5_API_33 というエミュレータがある場合
flutter emulators --launch Pixel_5_API_33
```

または、Android Studioから起動：
1. Android Studioを開く
2. 「Tools」→「Device Manager」を選択
3. エミュレータを選択して「▶」ボタンをクリック

#### 3. エミュレータが起動したら、デバイスを確認

```bash
flutter devices
```

#### 4. E2Eテストを実行

```bash
flutter test integration_test/app_test.dart -d android
```

### 方法2: Android実機を接続する

#### 1. USBデバッグを有効化

Android実機で：
1. 「設定」→「開発者向けオプション」を開く
2. 「USBデバッグ」を有効化

#### 2. USBケーブルで接続

#### 3. デバイスを確認

```bash
adb devices
```

デバイスが表示されれば接続成功です。

#### 4. E2Eテストを実行

```bash
flutter test integration_test/app_test.dart -d android
```

### 方法3: iOSシミュレータを使用する（Macのみ）

#### 1. シミュレータを起動

```bash
# 利用可能なシミュレータを確認
xcrun simctl list devices available

# シミュレータを起動（例: iPhone 15 Pro）
open -a Simulator
```

または、Xcodeから起動：
1. Xcodeを開く
2. 「Xcode」→「Open Developer Tool」→「Simulator」を選択

#### 2. デバイスを確認

```bash
flutter devices
```

#### 3. E2Eテストを実行

```bash
flutter test integration_test/app_test.dart -d ios
```

### 方法4: 統合テストを実行する（デバイス不要）

E2Eテストではなく、統合テスト（`test/integration/`）を実行する場合：

```bash
# 統合テストはデバイス不要で実行可能
flutter test test/integration/game_flow_test.dart
```

統合テストは`SharedPreferences`をモックしているため、エミュレータや実機がなくても実行できます。

## トラブルシューティング

### エミュレータが起動しない場合

1. Android Studioでエミュレータが正しく設定されているか確認
2. AVD（Android Virtual Device）が作成されているか確認
3. エミュレータのシステムイメージがダウンロードされているか確認

### 実機が認識されない場合

1. USBデバッグが有効になっているか確認
2. USBケーブルがデータ転送対応か確認
3. デバイスのドライバがインストールされているか確認（Windowsの場合）

### その他の問題

```bash
# Flutter環境を再確認
flutter doctor -v

# デバイス接続のタイムアウトを延長
flutter test integration_test/app_test.dart --device-timeout 60
```

## 推奨事項

開発中は、統合テスト（`test/integration/game_flow_test.dart`）を使用することを推奨します：
- デバイス不要で実行可能
- 実行が高速
- CI/CDでも簡単に実行可能

E2Eテストは、リリース前の最終確認や、実際のデバイスでの動作確認に使用することを推奨します。
