# プロジェクト構造

## ディレクトリ構成
```
clock_learning/
├── .kiro/                    # Kiro仕様管理
│   ├── steering/             # プロジェクト全体のガイドライン
│   └── specs/                # 機能別仕様
├── android/                   # Android固有ファイル
├── ios/                       # iOS固有ファイル
├── lib/                       # Dartソースコード
│   └── main.dart             # エントリーポイント
├── test/                      # テストコード
├── pubspec.yaml              # 依存関係定義
└── README.md                 # プロジェクト説明
```

## コード構造方針（予定）
```
lib/
├── main.dart                 # アプリエントリーポイント
├── models/                   # データモデル
├── screens/                  # 画面（ページ）
├── widgets/                  # 再利用可能なウィジェット
├── services/                 # ビジネスロジック・サービス
├── utils/                    # ユーティリティ関数
└── constants/               # 定数定義
```

## 命名規則
- **ファイル名**: snake_case（例: `clock_widget.dart`）
- **クラス名**: PascalCase（例: `ClockWidget`）
- **変数・関数名**: camelCase（例: `currentTime`）
- **定数**: lowerCamelCase with `const`（例: `const maxLevel = 10`）

## ファイル組織原則
- 1ファイル1クラス（小規模ウィジェットは例外可）
- 機能ごとにディレクトリを分離
- 再利用可能なコンポーネントは`widgets/`に配置
- 画面レベルのコンポーネントは`screens/`に配置
