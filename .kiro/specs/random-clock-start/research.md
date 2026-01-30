# Research & Design Decisions Template

---
**Purpose**: 拡張機能の統合ポイントと設計判断の根拠を記録する。
---

## Summary
- **Feature**: random-clock-start
- **Discovery Scope**: Extension（既存ゲーム画面・時計初期化の拡張）
- **Key Findings**:
  - 時計の開始時刻は `GameState._generateNextProblem()` 内で `clockController.initialize(12, 0, level)` に固定されている
  - `ClockController.initialize(int hour, int minute, Level level)` は既に任意の (hour, minute) を受け付けるためインターフェース変更不要
  - レベル別の有効な「分」は既存モデルで定義済み（easy: 0のみ、normal: FiveMinuteInterval、hard: 0〜59）

## Research Log

### 拡張ポイントの特定
- **Context**: 問題表示時の時計開始をランダムにする変更箇所の特定
- **Sources Consulted**: `lib/screens/game_screen.dart`, `lib/widgets/clock_controller.dart`, `lib/models/level.dart`, `lib/models/five_minute_interval.dart`
- **Findings**:
  - 変更対象は `game_screen.dart` の `GameState._generateNextProblem()` 内の `clockController.initialize(12, 0, level)` 呼び出しのみ
  - `ClockController` のシグネチャは変更不要（hour, minute を外部から渡すだけ）
  - 問題生成（`problemGenerator.generateProblem`）と正解判定（`checkAnswer`）は変更不要
- **Implications**: 新規コンポーネントは「レベルに応じたランダムな (hour, minute) を返す責務」に限定し、既存の GameState / ClockController の契約を維持する

### レベル別「分」の有効範囲
- **Context**: 要件 1.3 に基づく開始「分」の有効範囲の確認
- **Sources Consulted**: `lib/models/level.dart`, `lib/models/five_minute_interval.dart`, `lib/widgets/clock_controller.dart` のスナップ仕様
- **Findings**:
  - かんたん: 分は常に 0（正時のみ）
  - ふつう: 5分刻み（0, 5, 10, …, 55）— `FiveMinuteInterval.values` で取得可能
  - むずかしい: 0〜59 の任意の整数
- **Implications**: ランダム開始時刻生成は Level を入力とし、上記範囲内の (hour, minute) を返すインターフェースとする

## Architecture Pattern Evaluation
本機能は既存レイヤー内の拡張のため、新規アーキテクチャパターンの導入は不要。既存のレイヤード構成（UI層 GameState / ウィジェット層 ClockController）を維持し、ランダム生成ロジックを utils に配置して単一責任とテスト容易性を確保する。

## Design Decisions

### Decision: ランダム開始時刻の生成責務の配置
- **Context**: レベルに応じたランダムな (hour, minute) を誰が計算するか
- **Alternatives Considered**:
  1. GameState 内にインラインで記述 — 変更ファイルは1つのみだが、ロジックの単体テストがしづらい
  2. utils に専用関数を追加 — テスト可能で、structure.md の「utils: ユーティリティ関数」に合致
  3. ProblemGeneratorService にメソッド追加 — 問題の「目標時刻」と「表示用開始時刻」は別概念のため責務が混在する
- **Selected Approach**: utils にレベルを引数に取り (hour, minute) を返す関数を追加する（例: `getRandomClockStart(Level level, [Random? random])`）。GameState はその結果を `clockController.initialize` に渡すのみとする。
- **Rationale**: 単一責任・テスト容易性・既存 steering（utils 層の活用）に合致する
- **Trade-offs**: ファイルが1つ増えるが、変更範囲は小さく既存パターンに沿う
- **Follow-up**: 実装時に Dart の `dart:math Random` を使用し、テストでは seed 可能な Random を渡して再現性を確保する

## Risks & Mitigations
- **既存テストの破綻**: 時計が常に12時開始であることを前提にしたテストがあれば、開始時刻をモックまたはランダム許容に変更する必要がある — 実装前に `test/` および `integration_test/` で該当箇所を確認する
- **乱数品質**: 学習アプリであり暗号論的乱数は不要。`dart:math Random` で十分 — 新規依存は不要

## References
- 既存仕様: `.kiro/specs/analog-clock-learning/`（参照のみ、本機能では変更しない）
- プロジェクト構造: `.kiro/steering/structure.md`
