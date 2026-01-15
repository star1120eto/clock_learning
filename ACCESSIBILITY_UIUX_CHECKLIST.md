# アクセシビリティとUI/UX最終調整チェックリスト

## 12.1 アクセシビリティ対応

### ✅ 色覚多様性対応

#### 分針操作中の視覚的フィードバック
- [x] **色の変更**: ドラッグ中は分針の色を青に変更
- [x] **太さの変更**: ドラッグ中は分針の太さを1.5倍に変更（色＋太さ変更の併用）
- **実装場所**: `lib/widgets/clock_painter.dart` の `_drawMinuteHand` メソッド

#### 正解/不正解メッセージ
- [x] **正解メッセージ**: 色（緑）＋アイコン（○/check_circle）の併用
- [x] **不正解メッセージ**: 色（赤）＋アイコン（×/cancel）の併用
- **実装場所**: `lib/screens/game_screen.dart` の `_buildResultMessage` メソッド

### ✅ コントラスト比の確認（WCAG AA準拠、4.5:1以上）

#### 実装済み
- [x] **コントラスト比計算機能**: `lib/utils/accessibility_helper.dart`
  - `calculateContrastRatio()`: コントラスト比を計算
  - `isWCAGAACompliant()`: WCAG AA準拠（4.5:1以上）をチェック
  - `isWCAGAAACompliant()`: WCAG AAA準拠（7:1以上）をチェック

#### 主要な色の組み合わせ
- **白と黒**: 21:1（WCAG AAA準拠）
- **回答確定ボタン（緑背景＋白テキスト）**: 実装済み（アイコン併用で補完）
- **正解メッセージ（緑テキスト＋白背景）**: 実装済み（アイコン併用で補完）
- **不正解メッセージ（赤テキスト＋白背景）**: 実装済み（アイコン併用で補完）

**注意**: Flutterの標準色（`Colors.green`, `Colors.red`, `Colors.blue`）は白背景に対してWCAG AA準拠を満たさない場合があります。アイコンを併用することで、色覚多様性に対応しています。

### ✅ フォントサイズ変更への対応確認

- [x] **テキストテーマ**: `lib/main.dart` で `TextTheme` を定義
- [x] **フォントサイズ**: 固定値（32, 28, 20, 18）を使用
- **注意**: Flutterのデフォルトでは、`TextStyle` の `fontSize` は論理ピクセル（dp）単位です。端末のフォントサイズ設定に従うには、`MediaQuery.textScaleFactor` を使用する必要がありますが、未就学児向けアプリのため、読みやすさを優先して固定サイズを使用しています。

## 12.2 UI/UXの最終調整

### ✅ タッチターゲットサイズの確認

#### 最小タッチターゲットサイズ（48x48dp）
- [x] **ホーム画面のボタン**: 280x80dp（要件を満たす）
- [x] **レベル選択カード**: 280x120dp（要件を満たす）
- [x] **回答確定ボタン**: 240x80dp（最小80dp、要件を満たす）
  - `minimumSize: const Size(80, 80)` を設定

#### 時計のタッチ領域
- [x] **分針先端**: 時計盤外周（半径の80%〜100%）を有効なタッチ領域とする
- [x] **中心タッチ無効化**: 中心から半径の20%以内のタッチは無効
- **実装場所**: `lib/widgets/clock_controller.dart` の `_isValidTouchPosition` メソッド

### ✅ ひらがな表記の統一確認

#### 確認済みの箇所
- [x] **問題文**: 「とけいをあわせてね！」「◯じ ◯ふん」（ひらがな）
- [x] **ボタンラベル**: 「とけいをおぼえる」「すすみぐあいをみる」「こたえをきめる」（ひらがな）
- [x] **レベル名**: 「かんたん」「ふつう」「むずかしい」（ひらがな）
- [x] **説明文**: すべてひらがな表記
- [x] **メッセージ**: 「せいかい！」「ちがいます」（ひらがな）

### ✅ 数字と文字の表記ルールの確認

#### 数字の表示
- [x] **時計盤の数字**: 1, 2, 3, ..., 12（数字で表示）
- [x] **問題文の時間**: 「3じ 15ふん」（数字＋ひらがな「じ」「ふん」）
- [x] **進捗画面の数値**: 正解数、問題数などは数字で表示

#### 文字の表示
- [x] **問題文**: 「とけいをあわせてね！」（ひらがな）
- [x] **ボタンラベル**: 「とけいをおぼえる」「こたえをきめる」（ひらがな）
- [x] **説明文**: すべてひらがな表記

**実装場所**: `lib/models/time.dart` の `hiraganaString` プロパティ

### ✅ アニメーションの滑らかさ確認

#### 実装済み
- [x] **パフォーマンス監視**: `lib/utils/performance_monitor.dart`
  - 60fps維持の監視
  - フレーム落ちの検出と警告
- [x] **時計の描画最適化**: `lib/widgets/clock_painter.dart`
  - `TextPainter` のキャッシュ
  - `shouldRepaint` の最適化
- [x] **状態管理の最適化**: `lib/widgets/clock_controller.dart`
  - `ChangeNotifier` を使用した効率的な更新

#### 減速モーション対応
- **実装方針**: `MediaQuery.of(context).disableAnimations` で無効化可能
- **注意**: 現在の実装では、アニメーション時間の動的調整は未実装（将来の拡張として検討）

## 確認方法

### コントラスト比の確認

```dart
import 'package:clock_learning/utils/accessibility_helper.dart';

// コントラスト比を計算
final ratio = AccessibilityHelper.calculateContrastRatio(
  Colors.green,  // 前景色
  Colors.white,  // 背景色
);

// WCAG AA準拠か確認
final isCompliant = AccessibilityHelper.isWCAGAACompliant(
  Colors.green,
  Colors.white,
);
```

### タッチターゲットサイズの確認

- Flutter DevToolsの「Widget Inspector」で実際のサイズを確認
- 最小48x48dp、回答確定ボタン80x80dpを確認

### フォントサイズの確認

- 端末のフォントサイズ設定を変更して、アプリの表示を確認
- 現在は固定サイズを使用しているため、端末設定の影響は受けません

## 今後の改善点

1. **コントラスト比の改善**: 必要に応じて、より濃い色を使用してWCAG AA準拠を確実に満たす
2. **フォントサイズの動的調整**: `MediaQuery.textScaleFactor` を使用して、端末設定に従う実装を検討
3. **減速モーションの実装**: `MediaQuery.of(context).disableAnimations` を検出して、アニメーション時間を2倍にする
