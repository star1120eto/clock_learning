# Research & Design Decisions Template

---
**Purpose**: 不正解時の「つぎのもんだい」ボタン追加に伴う拡張の統合ポイントと設計判断を記録する。
---

## Summary
- **Feature**: next-problem-after-wrong
- **Discovery Scope**: Extension（既存ゲーム画面の回答後フロー拡張）
- **Key Findings**:
  - 現在は `GameState.checkAnswer()` 内で正解・不正解とも 1.5 秒後に `_generateNextProblem()` を呼び自動進行している
  - 不正解時は `_buildResultMessage(false)` で「ちがいます」「せいかいは◯です」を表示しているが、その後に「つぎのもんだい」ボタンはない
  - 正解時は従来どおり自動進行を維持するため、`checkAnswer()` の分岐（正解時のみ delay + 次問題）と UI の条件表示（不正解時のみ「つぎのもんだい」表示）が必要

## Research Log

### 拡張ポイントの特定
- **Context**: 不正解時に自動進行をやめ、「つぎのもんだい」で次に進む変更箇所の特定
- **Sources Consulted**: `lib/screens/game_screen.dart`（GameState.checkAnswer, _buildResultMessage, 回答確定ボタン）
- **Findings**:
  - 変更対象は `GameState.checkAnswer()` の末尾（不正解のときは delay と `_generateNextProblem()` を実行しない）
  - 新規に `GameState.goToNextProblem()` を公開し、UI の「つぎのもんだい」タップで `_generateNextProblem()` を呼ぶ
  - 画面側は `lastResult == false` のときに「つぎのもんだい」ボタンを表示し、タップで `goToNextProblem()` を呼ぶ。`lastResult == true` のときは従来どおり「こたえをきめる」のみ表示（自動進行のため）
- **Implications**: GameState に公開メソッド 1 つ追加、checkAnswer の分岐、GameScreen の結果表示ブロックにボタン条件追加

### UI ボタン表示方針
- **Context**: 「こたえをきめる」と「つぎのもんだい」の両立
- **Findings**:
  - 回答前（lastResult == null）: 「こたえをきめる」のみ表示
  - 正解後（lastResult == true）: 正解メッセージ表示、1.5 秒で自動進行のためボタンは「こたえをきめる」のままでも可（すぐ次に進む）
  - 不正解後（lastResult == false）: 「ちがいます」+ 正解表示 + 「つぎのもんだい」を表示。「こたえをきめる」は非表示または「つぎのもんだい」に差し替え
- **Implications**: 不正解時は結果エリア内または直下に「つぎのもんだい」を配置し、そのタップで `goToNextProblem()` を呼ぶ

## Architecture Pattern Evaluation
既存のレイヤー構成（screens: GameState + GameScreen UI）を維持。新規サービスやウィジェットは不要。GameState の公開 API に `goToNextProblem()` を追加し、UI から呼ぶだけの小規模拡張。

## Design Decisions

### Decision: 不正解時のみ手動進行とする
- **Context**: 要件では不正解時に「つぎのもんだい」で進むこと、正解時は従来どおり自動進行
- **Alternatives Considered**:
  1. 正解・不正解とも「つぎのもんだい」にする — 要件外のため不採用
  2. 不正解時のみボタンで次へ進む（正解時は delay 後に自動） — 要件どおり
- **Selected Approach**: `checkAnswer()` 内で `isCorrect` が true のときだけ `await Future.delayed(1500); _generateNextProblem();` を実行。false のときは何もせず return。UI で lastResult == false のとき「つぎのもんだい」を表示し、タップで `goToNextProblem()` → `_generateNextProblem()` を呼ぶ
- **Rationale**: 既存の正解フローを変えず、不正解フローのみ変更する最小変更で要件を満たす
- **Trade-offs**: 正解と不正解で進行トリガーが異なるが、要件・UX と一致する
- **Follow-up**: 実装時に「こたえをきめる」を lastResult == false のとき非表示にするか、「つぎのもんだい」に差し替えるかを統一する

## Risks & Mitigations
- **既存テストの破綻**: checkAnswer 後に自動で次問題に進むことを前提にしたテストがあれば、不正解時は進まない前提に変更する — 実装前に test/ で checkAnswer や game フローを検索して確認する
- **二重タップ**: goToNextProblem 連打で複数回 _generateNextProblem が走る可能性 — 実行中フラグや 1 回だけ進める制御で軽減可能（必要なら実装時に対応）

## References
- 既存仕様: `.kiro/specs/analog-clock-learning/`, `.kiro/specs/random-clock-start/`
- プロジェクト構造: `.kiro/steering/structure.md`
