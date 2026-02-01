# Research & Design Decisions: wrong-answer-clock-display

## Summary
- **Feature**: wrong-answer-clock-display
- **Discovery Scope**: Extension（既存ゲーム画面・時計ウィジェットの拡張）
- **Key Findings**:
  - 時計の針・文字盤は `ClockPainter` が `ClockState`（hour, minute, hourAngle, minuteAngle）に基づいて描画している。文字盤色は現在 `_drawClockFace` 内で白固定。
  - `ClockWidget` は `ClockController.getCurrentState()` を `ClockPainter` に渡し、GestureDetector でドラッグ操作をコントローラに伝えている。
  - `GameScreen` は `gameState.lastResult` と `gameState.currentProblem!.targetTime` を参照可能。不正解時のみ「時計に正解表示」「文字盤緑」を適用する条件が揃っている。
  - 角度計算（hour/minute → angle）は `ClockController` の `_calculateHourAngle` / `_calculateMinuteAngle` にのみ存在。表示用の「正解時刻の ClockState」を一箇所で生成するには Controller に公開メソッドを追加するのが一貫する。

## Research Log

### 拡張ポイントの特定
- **Context**: 不正解時に時計を正解時刻で表示し、背景を緑にするための変更箇所を特定する。
- **Sources Consulted**: `lib/widgets/clock_painter.dart`, `lib/widgets/clock_widget.dart`, `lib/widgets/clock_controller.dart`, `lib/screens/game_screen.dart`
- **Findings**:
  - `ClockPainter._drawClockFace`: 現在 `Colors.white` で fill。色をパラメータ化すれば緑に切り替え可能。
  - `ClockPainter` は `ClockState` を受け取り針を描画。正解表示時は「ユーザー操作の state」ではなく「正解の hour/minute から得た state」を渡す必要がある。
  - `ClockController` の `_updateState(hour, minute)` および `_calculateHourAngle` / `_calculateMinuteAngle` が角度計算を担当。同一ロジックを表示専用で使うため、Controller に `getStateForTime(hour, minute)` のような公開メソッドを追加する案が自然。
- **Implications**: 変更は widgets 層（ClockPainter, ClockWidget, ClockController）と screens 層（GameScreen）に限定。services / models は変更不要。

### 不正解時の操作無効化
- **Context**: 不正解表示中は時計を正解で固定表示するため、ドラッグで針を動かせないようにする必要がある。
- **Findings**:
  - `ClockWidget` は `GestureDetector` で onPanStart/Update/End を `ClockController` に渡している。不正解表示中は GestureDetector を無効化するか、onPan で何もしないようにすればよい。
  - 既存の `ClockController.onTouchStart` は `animatingResult` のとき return している。同様に「表示オーバーライド中」は Controller 側で無視するか、Widget 側で GestureDetector を外す/無効化するかのいずれか。Widget 側で制御する方が状態の流れが明確（GameScreen → ClockWidget に「正解表示中」を渡すだけ）。
- **Implications**: ClockWidget に `displayCorrectTime`（または `interactive`）フラグを渡し、true のときは GestureDetector を無効化する設計で足りる。

## Architecture Pattern Evaluation

| Option | Description | Strengths | Risks / Limitations | Notes |
|--------|-------------|-----------|---------------------|-------|
| 表示状態を GameScreen で保持 | GameScreen が lastResult と currentProblem から「正解表示用 hour/minute」を計算し、ClockWidget に渡す | 既存の GameState の境界を変えず、表示専用の props が増えるだけ | なし | 採用 |
| 表示状態を GameState に保持 | GameState に showCorrectOnClock, correctHour, correctMinute を追加 | 状態が一箇所に集約 | GameState が「表示モード」を抱え、UI と状態の責務が混在しやすい | 不採用 |
| ClockController に表示モードを追加 | Controller に setDisplayOverride(hour, minute) を追加し、getCurrentState() がオーバーライド時はその時刻を返す | 呼び出し側は getCurrentState() だけ使えばよい | Controller が「ユーザー操作の状態」と「表示オーバーライド」の二重の責務を持ち、テスト・理解が複雑化 | 不採用 |

## Design Decisions

### Decision: 正解表示用の ClockState の生成場所
- **Context**: 正解の hour/minute から針の角度を持つ ClockState を誰が作るか。
- **Alternatives Considered**:
  1. ClockController に `getStateForTime(int hour, int minute)` を追加し、既存の角度計算を再利用する。
  2. ClockWidget または utils に hour/minute → angles の計算を重複実装する。
- **Selected Approach**: ClockController に `getStateForDisplay(int hour, int minute)`（または `getStateForTime`）を追加し、内部の _calculateHourAngle / _calculateMinuteAngle を使って ClockState を返す。ClockWidget は不正解時に GameScreen から渡された correctHour / correctMinute でこのメソッドを呼び、得た state を ClockPainter に渡す。
- **Rationale**: 角度計算が一箇所にまとまり、将来の仕様変更（例: 針のオフセット変更）にも強い。
- **Trade-offs**: Controller が「操作状態」に加えて「表示用 state のファクトリ」の役割を持つが、入力は hour/minute のみで副作用なしのため許容範囲。

### Decision: 文字盤の緑色をどこで指定するか
- **Context**: 不正解時のみ時計の文字盤を緑にする制御をどの層で行うか。
- **Selected Approach**: GameScreen が lastResult == false のとき `faceBackgroundGreen: true` を ClockWidget に渡す。ClockWidget はその値を ClockPainter に渡し、ClockPainter の _drawClockFace で true のとき緑、false のとき白で描画する。
- **Rationale**: 「いつ緑にするか」はゲームの状態（lastResult）に依存するため、GameScreen が知っていて渡すのが自然。Painter は「描画の見た目」だけを受け取る。

## Risks & Mitigations
- **角度計算の二重化**: Controller の getStateForDisplay が既存の _updateState とずれないよう、同じ _calculateHourAngle / _calculateMinuteAngle を利用する。実装時に unit テストで一致を確認する。
- **色のアクセシビリティ**: 緑背景と針・数字のコントラストが既存のアクセシビリティ方針（WCAG AA 等）を満たすか、実装後に確認する。必要なら research.md または design に「緑は〇〇相当」とメモする。

## References
- 既存構造: `.kiro/steering/structure.md`, `.kiro/steering/tech.md`
- 関連仕様: `.kiro/specs/next-problem-after-wrong/design.md`（不正解表示フロー）
