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

#### コマンド一覧

| フェーズ | コマンド | 説明 |
|---------|---------|------|
| 要件定義 | `/kiro:spec-init <スペック名>` | 仕様書フォルダを自動生成し、概要をまとめる |
| 要件の詳細化 | `/kiro:spec-requirements <スペック名>` | 必要な機能・条件をAIと一緒に整理 |
| 設計 | `/kiro:spec-design <スペック名>` | データ構造や画面設計などを自動生成 |
| 実装計画 | `/kiro:spec-tasks <スペック名>` | 実装タスクを一覧化して開発手順を明確化 |
| 実装 | `/kiro:spec-impl <スペック名>` | コードを生成・確認してAIと共同開発 |
| 進捗確認 | `/kiro:spec-status <スペック名>` | 仕様の進捗状況を確認 |

#### Steering設定（任意）

プロジェクト全体のコンテキストをAIに伝えるためのステアリング設定を行います。

| コマンド | 説明 |
|---------|------|
| `/kiro:steering` | ステアリング設定の確認・更新 |
| `/kiro:steering-custom` | カスタムステアリングの追加 |

#### 検証コマンド（任意）

| コマンド | 説明 |
|---------|------|
| `/kiro:validate-gap <スペック名>` | 既存コードとのギャップ分析 |
| `/kiro:validate-design <スペック名>` | 設計レビュー |
| `/kiro:validate-impl <スペック名>` | 実装の検証 |

### 開発ルール

1. **3フェーズ承認ワークフロー**: Requirements → Design → Tasks → Implementation
2. **人間のレビュー必須**: 各フェーズで人間のレビューを行う（`-y`オプションで意図的にスキップ可能）
3. **ステアリングの維持**: プロジェクトのコンテキストを最新に保つ
4. **自律的な作業**: 指示の範囲内で必要なコンテキストを収集し、作業を完了させる

### 参考ドキュメント

#### 開発・ビルド

- [BUILD_GUIDE.md](./BUILD_GUIDE.md) - ビルドガイド（各プラットフォーム向け）
- [AGENTS.md](./AGENTS.md) - AI-DLCとSpec Driven Developmentの詳細

#### 品質・テスト

- [GOLDEN_TEST_README.md](./GOLDEN_TEST_README.md) - ゴールデンテストガイド
- [E2E_TEST_README.md](./E2E_TEST_README.md) - E2Eテスト概要
- [E2E_SETUP_GUIDE.md](./E2E_SETUP_GUIDE.md) - E2Eテスト環境構築
- [E2E_EXECUTION_GUIDE.md](./E2E_EXECUTION_GUIDE.md) - E2Eテスト実行ガイド

#### アクセシビリティ・UX

- [ACCESSIBILITY_UIUX_CHECKLIST.md](./ACCESSIBILITY_UIUX_CHECKLIST.md) - アクセシビリティ・UXチェックリスト
