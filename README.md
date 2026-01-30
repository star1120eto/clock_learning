# clock_learning

子供向けのアナログ時計学習アプリ（Flutterプロジェクト）

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

## CCSDD（Cursor Composer Spec Driven Development）開発フロー

本プロジェクトでは、AIを活用したスペック駆動開発（CCSDD）を採用しています。

### 概要

CCSDDは、Kiroスタイルのスペック駆動開発をCursor Composer上で実現するワークフローです。
要件定義 → 設計 → タスク分解 → 実装の各フェーズで人間のレビューを挟み、品質を担保しながら効率的に開発を進めます。

### ディレクトリ構成

```
.kiro/
├── steering/          # プロジェクト全体のガイドライン
│   ├── product.md     # プロダクト情報
│   ├── tech.md        # 技術スタック
│   └── structure.md   # プロジェクト構造
└── specs/             # 機能ごとの仕様書
    └── {feature}/
        ├── spec.json       # 仕様メタ情報
        ├── requirements.md # 要件定義
        ├── design.md       # 設計ドキュメント
        └── tasks.md        # タスクリスト
```

### 開発フロー

#### Phase 0: Steering設定（任意）

プロジェクト全体のコンテキストをAIに伝えるためのステアリング設定を行います。

```
/kiro/steering              # ステアリング設定の確認・更新
/kiro/steering-custom       # カスタムステアリングの追加
```

#### Phase 1: 仕様策定

新機能の開発は、仕様の策定から始めます。

```bash
# 1. 仕様の初期化
/kiro/spec-init "機能の説明"

# 2. 要件定義の作成
/kiro/spec-requirements {feature}

# 3. （任意）既存コードとのギャップ分析
/kiro/validate-gap {feature}

# 4. 設計ドキュメントの作成
/kiro/spec-design {feature}

# 5. （任意）設計レビュー
/kiro/validate-design {feature}

# 6. タスク分解
/kiro/spec-tasks {feature}
```

#### Phase 2: 実装

仕様が承認されたら、タスクに基づいて実装を進めます。

```bash
# 実装の実行
/kiro/spec-impl {feature} [tasks]

# （任意）実装の検証
/kiro/validate-impl {feature}
```

#### 進捗確認

いつでも仕様の進捗状況を確認できます。

```bash
/kiro/spec-status {feature}
```

### 開発ルール

1. **3フェーズ承認ワークフロー**: Requirements → Design → Tasks → Implementation
2. **人間のレビュー必須**: 各フェーズで人間のレビューを行う（`-y`オプションで意図的にスキップ可能）
3. **ステアリングの維持**: プロジェクトのコンテキストを最新に保つ
4. **自律的な作業**: 指示の範囲内で必要なコンテキストを収集し、作業を完了させる

### 参考ドキュメント

- [AGENTS.md](./AGENTS.md) - AI-DLCとSpec Driven Developmentの詳細
- [ACCESSIBILITY_UIUX_CHECKLIST.md](./ACCESSIBILITY_UIUX_CHECKLIST.md) - アクセシビリティ・UXチェックリスト
- [GOLDEN_TEST_README.md](./GOLDEN_TEST_README.md) - ゴールデンテストガイド
- [E2E_TEST_README.md](./E2E_TEST_README.md) - E2Eテストガイド
