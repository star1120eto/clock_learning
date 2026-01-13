# Implementation Plan

## Task Format Template

Use whichever pattern fits the work breakdown:

### Major task only
- [ ] {{NUMBER}}. {{TASK_DESCRIPTION}}{{PARALLEL_MARK}}
  - {{DETAIL_ITEM_1}} *(Include details only when needed. If the task stands alone, omit bullet items.)*
  - _Requirements: {{REQUIREMENT_IDS}}_

### Major + Sub-task structure
- [ ] {{MAJOR_NUMBER}}. {{MAJOR_TASK_SUMMARY}}
- [ ] {{MAJOR_NUMBER}}.{{SUB_NUMBER}} {{SUB_TASK_DESCRIPTION}}{{SUB_PARALLEL_MARK}}
  - {{DETAIL_ITEM_1}}
  - {{DETAIL_ITEM_2}}
  - _Requirements: {{REQUIREMENT_IDS}}_ *(IDs only; do not add descriptions or parentheses.)*

> **Parallel marker**: Append `(P)` only to tasks that can be executed in parallel. Omit the marker when running in `--sequential` mode.
>
> **Optional test coverage**: When a sub-task is deferrable test work tied to acceptance criteria, mark the checkbox as `- [ ]*` and explain the referenced requirements in the detail bullets.

- [x] 1. プロジェクトセットアップと依存関係の追加
- [x] 1.1 依存関係パッケージの追加
  - pubspec.yamlにProvider、SharedPreferences、audioplayers、Lottieを追加
  - flutter pub getを実行してパッケージをインストール
  - _Requirements: -_

- [x] 1.2 プロジェクトディレクトリ構造の作成
  - lib/models/、lib/screens/、lib/widgets/、lib/services/、lib/utils/、lib/constants/ディレクトリを作成
  - 命名規則に従ったディレクトリ構造を確立
  - _Requirements: -_

- [x] 1.3 アセットディレクトリの作成
  - assets/audio/、assets/animations/ディレクトリを作成
  - pubspec.yamlにアセットパスを追加
  - _Requirements: -_

- [x] 1.4 アプリの基本設定
  - 縦向き（Portrait）固定の設定
  - アプリタイトルとテーマの基本設定
  - _Requirements: 8.1, 8.2, 8.6_

- [x] 2. データモデルの実装
- [x] 2.1 (P) Time値オブジェクトの実装
  - hour（1〜12）、minute（0〜59）を持つ値オブジェクト
  - バリデーションと不変条件の実装
  - 内部計算用の0〜11変換メソッド
  - _Requirements: 1.1, 3.1, 4.1, 5.1_

- [x] 2.2 (P) Problemエンティティの実装
  - sealed classでEasyProblem、NormalProblem、HardProblemを定義
  - FiveMinuteInterval enumの実装
  - 問題文のひらがな表記生成メソッド
  - _Requirements: 2.3, 2.4, 2.5, 3.1, 4.1, 5.1_

- [x] 2.3 (P) ProgressData集約ルートの実装
  - LevelProgress、Achievementクラスの実装
  - 正解率計算メソッド
  - 連続学習日数計算ロジック
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 2.4 (P) Level enumの実装
  - easy、normal、hardの3つのレベルを定義
  - レベル名のひらがな表記メソッド
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 3. サービス層の実装
- [x] 3.1 (P) StorageServiceの実装
  - SharedPreferencesを使用したデータ永続化
  - スキーマバージョン管理（v1）
  - ProgressLoadResult sealed classの実装（Success、Corrupted、FirstLaunch）
  - データの保存・読み込み・削除メソッド
  - バックアップ・リストア機能（エクスポート/インポート）
  - _Requirements: 7.1, 10.1, 10.2, 10.4_

- [x] 3.2 (P) ProblemGeneratorサービスの実装
  - レベルに応じた問題生成ロジック
  - 直近10問との重複チェック機能
  - 正解判定ロジック
  - 問題文のひらがな表記生成
  - _Requirements: 2.2, 2.3, 2.4, 2.5, 3.1, 4.1, 5.1_

- [x] 3.3 ProgressServiceの実装
  - 進捗データの記録と更新
  - 正解率の計算
  - 学習日数の追跡
  - 達成バッジの管理
  - 連続学習日数の計算
  - StorageServiceとの連携（3.1完了後に実装）
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 3.4 (P) AudioServiceの実装
  - audioplayersを使用した音声再生
  - 正解・不正解音声の再生
  - ミュート機能と音量制御
  - 音声アセットの管理（OGG形式）
  - _Requirements: 3.5, 4.6, 5.6, 8.4_

- [x] 4. ClockControllerの実装
- [x] 4.1 ClockControllerの基本実装
  - ClockStateとClockInteractionStateの定義
  - 時計の初期化メソッド
  - 現在の時間取得メソッド
  - _Requirements: 1.1, 1.4, 1.7, 1.8_

- [x] 4.2 分針角度計算ロジックの実装
  - タッチ位置から分針角度への変換
  - レベルに応じたスナップ計算（かんたん：0分、ふつう：5分刻み、むずかしい：1分刻み）
  - 高速ドラッグ対応のフレーム間補間
  - _Requirements: 1.8, 4.4, 5.4_

- [x] 4.3 時針自動調整アルゴリズムの実装
  - 分針角度から時針角度への自動計算
  - 計算式の実装（hour * 30度 + minute * 0.5度）
  - 状態更新の通知
  - _Requirements: 1.2, 3.3, 4.3, 5.3_

- [x] 4.4 タッチ操作ハンドラーの実装
  - onTouchStart、onDragUpdate、onTouchEndメソッド
  - 有効なタッチ位置の判定（時計盤外周、分針領域）
  - 無効なタッチの無視（時針領域、中心領域）
  - 2本指操作の無効化
  - _Requirements: 1.7, 1.8, 8.1_

- [x] 5. ClockPainterの実装
- [x] 5.1 (P) ClockPainterの基本実装
  - CustomPainterを継承した描画クラス
  - 時計盤の円形描画
  - 1〜12の数字の配置と描画
  - _Requirements: 1.1, 1.3, 1.5_

- [x] 5.2 時針・分針の描画実装
  - 時針・分針の描画（太さ、長さ、色の区別）
  - 角度に応じた針の回転描画
  - ドラッグ中の視覚的フィードバック（分針の色変更）
  - _Requirements: 1.2, 1.5, 8.1, 8.2_

- [x] 5.3 パフォーマンス最適化
  - shouldRepaintで再描画の必要性を判定
  - 角度が変更された場合のみ再描画
  - _Requirements: 9.2_

- [x] 6. ClockWidgetの実装
- [x] 6.1 ClockWidgetの基本実装
  - ClockPainterを使用した時計描画
  - ClockControllerとの連携
  - 状態の受け取りと表示
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6_

- [x] 6.2 タッチ操作の実装
  - GestureDetectorでタッチ操作を検出
  - タッチターゲットの拡大（時計盤外周、分針全体）
  - タッチ位置の判定とClockControllerへの通知
  - 誤操作防止（時針領域、中心領域の無視）
  - 2本指操作の無効化
  - _Requirements: 1.7, 1.8, 8.1_

- [x] 6.3 アニメーション実装
  - 分針操作時のスムーズなアニメーション
  - スナップアニメーション（ふつうレベル）
  - 60fps維持の最適化
  - _Requirements: 1.5, 4.4, 9.2_

- [x] 7. UI画面の実装
- [x] 7.1 HomeScreenの実装
  - アプリ起動時の初期画面
  - 学習開始ボタンと進捗確認ボタン
  - 大きなボタンとカラフルなデザイン
  - ひらがな表記のボタンラベル
  - LevelSelectScreen、ProgressScreenへの遷移
  - _Requirements: 1.1, 8.1, 8.2, 8.3, 8.7, 8.8_

- [x] 7.2 LevelSelectScreenの実装
  - 3つのレベルボタン（かんたん、ふつう、むずかしい）
  - 大きなカード型ボタンとアニメーション
  - レベル選択時のGameScreenへの遷移（Navigator引数）
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 8.1, 8.2, 8.3, 8.6, 8.8_

- [x] 7.3 GameScreenの基本実装
  - Providerを使用したGameState管理
  - 問題文の表示（ひらがな表記）
  - ClockWidgetの表示
  - レベル情報の受け取りと問題生成
  - _Requirements: 1.1, 2.2, 3.1, 4.1, 5.1, 8.1, 8.2, 8.3, 8.7, 8.8_

- [x] 7.4 GameScreenの正解判定機能
  - 回答確定ボタンの実装（位置、サイズ、ラベル）
  - ClockControllerから現在の時間取得
  - 正解・不正解の判定ロジック
  - 正解時の成功アニメーション（Lottie、800ms）
  - 不正解時の説明表示（ひらがな表記）
  - 正解時計アニメーション（500ms）
  - _Requirements: 3.4, 3.5, 3.6, 4.5, 4.6, 4.7, 5.5, 5.6, 5.7, 8.1, 8.2, 8.3, 8.5, 8.7, 8.8_

- [x] 7.5 GameScreenの進捗記録機能
  - ProgressServiceへの進捗記録
  - 次の問題への自動遷移
  - 問題重複排除の実装
  - _Requirements: 3.7, 4.8, 5.8, 6.1, 6.2, 7.1, 7.2_

- [x] 7.6 GameScreenの音声フィードバック統合
  - AudioServiceとの連携
  - 正解・不正解時の音声再生
  - _Requirements: 3.5, 4.6, 5.6, 8.4_

- [x] 7.7 ProgressScreenの実装
  - 進捗データの表示（完了レベル、正解率、学習日数）
  - 達成バッジやメダルの表示
  - 連続学習日数の表示
  - ProgressServiceからのデータ取得
  - カラフルなカード型UI
  - _Requirements: 7.3, 7.4, 7.5, 8.1, 8.2, 8.7, 8.8_

- [ ] 8. アプリ統合とメインエントリーポイント
- [ ] 8.1 main.dartの更新
  - MaterialAppの設定
  - Providerの設定
  - テーマの設定（カラフルなデザイン）
  - 初期画面をHomeScreenに設定
  - _Requirements: 1.1, 8.1, 8.2_

- [ ] 8.2 画面遷移の統合
  - HomeScreen → LevelSelectScreen → GameScreenの遷移
  - HomeScreen → ProgressScreenの遷移
  - Navigator引数を使用したデータ受け渡し
  - _Requirements: 1.1, 2.1, 2.2, 7.3_

- [ ] 8.3 サービス層の統合
  - 各サービスの初期化と依存性注入
  - Provider経由でのサービス提供
  - _Requirements: -_

- [ ] 9. エラーハンドリングとエッジケース対応
- [ ] 9.1 データ読み込みエラー処理
  - ProgressLoadResultの処理（Success、Corrupted、FirstLaunch）
  - データ破損時のユーザー通知（ひらがな表記）
  - 初回起動時のオンボーディング表示
  - _Requirements: 7.1, 8.5_

- [ ] 9.2 エッジケース対応
  - 12時0分の問題表示（「12時」と表示）
  - 時計盤中心タッチの無視
  - 画面外ドラッグの無効化
  - 高速ドラッグの対応
  - 画面回転の固定（縦向きのみ）
  - _Requirements: 1.7, 1.8, 8.1_

- [ ] 10. パフォーマンス最適化
- [ ] 10.1 アニメーションパフォーマンス
  - 60fps維持の確認と最適化
  - フレームタイミングの監視
  - アラート閾値の実装（3フレーム連続で16.67ms超過）
  - _Requirements: 9.2_

- [ ] 10.2 メモリ使用量の最適化
  - メモリ使用量の監視（目標50MB以下）
  - 不要なデータの削除
  - アセットサイズの最適化
  - _Requirements: 9.3_

- [ ] 10.3 起動時間の最適化
  - データ読み込みの非同期化
  - 3秒以内の初期画面表示
  - _Requirements: 9.1_

- [ ] 11. テスト実装
- [ ] 11.1 (P) データモデルのユニットテスト
  - Time値オブジェクトのテスト
  - Problemエンティティのテスト
  - ProgressDataのテスト
  - _Requirements: -_

- [ ] 11.2 (P) サービス層のユニットテスト
  - StorageServiceのテスト（保存・読み込み・エラー処理）
  - ProblemGeneratorのテスト（各レベルの問題生成、重複チェック）
  - ProgressServiceのテスト（進捗記録、正解率計算）
  - AudioServiceのテスト（音声再生、ミュート機能）
  - _Requirements: -_

- [ ] 11.3 (P) ClockControllerのユニットテスト
  - 分針角度計算のテスト
  - 時針自動調整アルゴリズムのテスト
  - スナップ計算のテスト（各レベル）
  - 境界値テスト（1時0分、12時0分、12時59分など）
  - _Requirements: -_

- [ ] 11.4 統合テスト
  - レベル選択からゲーム開始までのフロー
  - 問題生成から正解判定までのフロー
  - 進捗記録から進捗表示までのフロー
  - _Requirements: -_

- [ ] 11.5 E2E/UIテスト
  - ホーム画面からレベル選択、ゲーム開始までのユーザーフロー
  - 分針操作から正解判定までのインタラクション
  - 未就学児特有の操作パターン（高速タップ、2本指操作など）
  - _Requirements: -_

- [ ] 11.6 Golden Test
  - 時計描画のピクセル単位検証
  - 各レベルの時計表示
  - 分針操作中の視覚的フィードバック
  - 正解・不正解時のアニメーション状態
  - _Requirements: -_

- [ ] 12. アクセシビリティとUI/UXの最終調整
- [ ] 12.1 アクセシビリティ対応
  - 色覚多様性対応（色＋アイコン、太さ変更）
  - コントラスト比の確認（WCAG AA準拠、4.5:1以上）
  - フォントサイズ変更への対応確認
  - _Requirements: 8.1, 8.2, 8.3_

- [ ] 12.2 UI/UXの最終調整
  - タッチターゲットサイズの確認（最小48x48dp、回答確定ボタン80x80dp）
  - ひらがな表記の統一確認
  - 数字と文字の表記ルールの確認
  - アニメーションの滑らかさ確認
  - _Requirements: 8.1, 8.2, 8.3, 8.7, 8.8_
