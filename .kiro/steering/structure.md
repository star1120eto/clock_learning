# プロジェクト構造

## ディレクトリ構成（実装済み）
```
clock_learning/
├── .kiro/                    # Kiro仕様管理
│   ├── steering/             # プロジェクト全体のガイドライン
│   └── specs/                # 機能別仕様
│       └── analog-clock-learning/
│           ├── requirements.md
│           ├── design.md
│           └── tasks.md
├── android/                   # Android固有ファイル
├── ios/                       # iOS固有ファイル
├── lib/                       # Dartソースコード（21ファイル）
│   ├── main.dart             # エントリーポイント
│   ├── models/               # データモデル（7ファイル）
│   ├── screens/               # 画面（4ファイル）
│   ├── widgets/               # ウィジェット（3ファイル）
│   ├── services/             # サービス（4ファイル）
│   ├── utils/                 # ユーティリティ（2ファイル）
│   └── constants/            # 定数
├── test/                      # テストコード（9ファイル）
│   ├── models/               # モデルテスト
│   ├── services/             # サービステスト
│   ├── widgets/               # ウィジェットテスト
│   ├── integration/          # 統合テスト
│   └── utils/                # ユーティリティテスト
├── integration_test/          # E2Eテスト
├── assets/                    # アセット
│   ├── audio/                # 音声ファイル
│   └── animations/           # アニメーションファイル
├── pubspec.yaml              # 依存関係定義
└── README.md                 # プロジェクト説明
```

## コード構造（実装済み）
```
lib/
├── main.dart                 # アプリエントリーポイント
├── models/                   # データモデル
│   ├── time.dart            # 時刻値オブジェクト
│   ├── problem.dart         # 問題エンティティ
│   ├── level.dart           # 難易度レベル
│   ├── level_progress.dart  # レベル別進捗
│   ├── achievement.dart     # 達成バッジ
│   ├── progress_data.dart   # 進捗データ集約ルート
│   └── five_minute_interval.dart
├── screens/                  # 画面（ページ）
│   ├── home_screen.dart     # ホーム画面
│   ├── level_select_screen.dart # レベル選択画面
│   ├── game_screen.dart     # ゲーム画面
│   └── progress_screen.dart # 進捗画面
├── widgets/                  # 再利用可能なウィジェット
│   ├── clock_widget.dart    # 時計ウィジェット
│   ├── clock_controller.dart # 時計操作コントローラー
│   └── clock_painter.dart   # 時計描画
├── services/                 # ビジネスロジック・サービス
│   ├── storage_service.dart # データ永続化
│   ├── progress_service.dart # 進捗管理
│   ├── problem_generator_service.dart # 問題生成
│   └── audio_service.dart   # 音声再生
├── utils/                    # ユーティリティ関数
│   ├── performance_monitor.dart # パフォーマンス監視
│   └── accessibility_helper.dart # アクセシビリティヘルパー
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
