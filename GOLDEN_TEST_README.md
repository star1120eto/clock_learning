# Golden Test 実行ガイド

## 概要

Golden Testは、時計ウィジェットの描画をピクセル単位で検証するテストです。UIの見た目が意図した通りに描画されているかを確認します。

## テストファイル

- `test/widgets/clock_widget_golden_test.dart`

## テスト内容

### 1. 各レベルの時計表示

- **かんたんレベル**
  - 12時0分
  - 3時0分

- **ふつうレベル**
  - 3時15分
  - 6時30分

- **むずかしいレベル**
  - 9時37分（1分刻み目盛り表示）
  - 12時59分

### 2. 分針操作中の視覚的フィードバック

- ドラッグ中の分針の色が青に変わることを確認

### 3. 異なるサイズでの時計表示

- 小さいサイズ（200px）
- 大きいサイズ（400px）

## 実行方法

### 初回実行（Goldenファイルの生成）

```bash
flutter test test/widgets/clock_widget_golden_test.dart --update-goldens
```

このコマンドを実行すると、`test/widgets/`ディレクトリに以下のGoldenファイルが生成されます：

- `clock_widget_easy_12_00.png`
- `clock_widget_easy_3_00.png`
- `clock_widget_normal_3_15.png`
- `clock_widget_normal_6_30.png`
- `clock_widget_hard_9_37.png`
- `clock_widget_hard_12_59.png`
- `clock_widget_dragging.png`
- `clock_widget_small_size.png`
- `clock_widget_large_size.png`

### 通常のテスト実行

```bash
flutter test test/widgets/clock_widget_golden_test.dart
```

このコマンドを実行すると、現在の描画結果とGoldenファイルを比較し、差分があればテストが失敗します。

### 特定のテストのみ実行

```bash
flutter test test/widgets/clock_widget_golden_test.dart --name "かんたんレベル"
```

## Goldenファイルの更新

UIの変更が意図的な場合（デザイン変更など）、Goldenファイルを更新する必要があります：

```bash
flutter test test/widgets/clock_widget_golden_test.dart --update-goldens
```

## トラブルシューティング

### テストが失敗する場合

1. **意図的な変更の場合**
   - `--update-goldens`フラグを使用してGoldenファイルを更新

2. **意図しない変更の場合**
   - コードの変更を確認
   - 描画ロジックに問題がないか確認

### Goldenファイルの場所

Goldenファイルは`test/widgets/`ディレクトリに保存されます。これらのファイルはGitにコミットする必要があります。

### プラットフォームによる差異

Golden Testはプラットフォーム（iOS、Android、Web）によって結果が異なる場合があります。特定のプラットフォームでテストを実行するには：

```bash
# iOS
flutter test test/widgets/clock_widget_golden_test.dart -d ios

# Android
flutter test test/widgets/clock_widget_golden_test.dart -d android

# Web
flutter test test/widgets/clock_widget_golden_test.dart -d chrome
```

## CI/CDでの実行

CI/CDパイプラインでGolden Testを実行する場合：

```yaml
# GitHub Actions の例
- name: Run Golden Tests
  run: flutter test test/widgets/clock_widget_golden_test.dart
```

Goldenファイルの更新が必要な場合は、手動で`--update-goldens`を実行し、変更をコミットする必要があります。

## 参考資料

- [Flutter Golden Tests](https://docs.flutter.dev/testing/ui-tests#golden-tests)
- [matchesGoldenFile](https://api.flutter.dev/flutter/flutter_test/matchesGoldenFile.html)
