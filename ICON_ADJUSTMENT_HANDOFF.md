# アプリアイコン調整 引き継ぎ資料

このドキュメントは、アプリアイコン (`assets/icon/icon.png`) の画像調整を
画像生成・編集が得意な別のAI/担当者に引き継ぐための要件定義です。

## 1. 問題の報告内容

ユーザー報告(原文): 「icon ga bimyouni hamatteinai tyouseiwoonegai」
(= 「アイコンが微妙にはまっていない、調整をお願いします」)

ホーム画面上のアプリアイコン(添付スクリーンショット)で以下の問題が確認された:

- 上部の**ベル(耳)の先端が見切れている**
- 右側の**ねじ巻き(リューズ)が大きく欠けている**
- 左端に**スケッチブックの綴じ・ページ端らしき不要な帯**が見えている

## 2. 原因

現在のソース画像 `assets/icon/icon.png` (1024×1024 PNG) は、スケッチブックの
見開きページに時計のイラストを描いたような構図になっている。

- 時計キャラクター(ベル〜足、ねじ巻き含む)がキャンバスの端ギリギリまで
  描かれており、余白(セーフマージン)がほとんど無い。
- さらにキャンバス周囲に、スケッチブック特有の装飾
  (スパイラル綴じの穴、ページの角のカール、濃紺の表紙の縁)が描き込まれている。

このため、Android の Adaptive Icon(円形/角丸/しずく形などランチャーが
自動でマスクをかける仕組み)や iOS の角丸マスクを適用すると、キャラクターの
外側の要素(ベル・ねじ巻き)が大きく削られ、かつ不要なノート装飾の断片が
アイコンの端に残ってしまう。

### 現ソース画像の実測値(1024×1024基準、左上原点)

| 要素 | 座標目安 |
|---|---|
| ベル頂点(上端) | y ≈ 140px |
| 足の裏(下端) | y ≈ 850px |
| 左足(左端) | x ≈ 170px |
| ねじ巻き先端(右端) | x ≈ 965px |
| ノート装飾(スパイラル綴じ穴) | x ≈ 40〜60px 付近(左端) |
| ノート装飾(濃紺の表紙の縁) | x ≈ 985〜1024px(右端)、y ≈ 990〜1024px(下端) |

→ キャラクター本体は横795px×縦710px(キャンバスの約78%×69%)を占め、
四方の安全マージンがほぼゼロの状態。

## 3. 新しいアイコン画像に求める要件

### 必須要件

1. **キャンバスサイズ**: 1024×1024px、PNG、不透明(アルファチャンネルなし推奨。
   iOS Appアイコンは透過不可のため)。
2. **ノート/スケッチブックの装飾を完全に除去**すること。
   - スパイラル綴じ、ページの角のカール、濃紺の表紙の縁は不要。
   - 背景はイラスト内の空・雲のみ、またはシンプルな単色/グラデーション背景にする。
3. **セーフゾーンの確保**: 時計キャラクター(ベル〜足、ねじ巻き含む)を、
   キャンバス中央 66〜72% 程度の範囲に収める(=キャンバス端から最低
   14〜17% の余白)。
   - 目安: 1024px キャンバスなら、キャラクターの外接矩形が概ね
     720〜760px 角に収まるようスケールし、中央に配置する。
   - これは Android Adaptive Icon の各種マスク形状、および PWA の
     maskable icon の安全円(直径80%)に対応するため。
4. **既存デザインを踏襲**: 時計の顔・表情・カラフルな数字・針・色鉛筆風の
   タッチなど、現在のかわいいイラストのデザインは大きく変更しない
   (ブランド一貫性のため)。
5. **背景色**: 単色 or グラデーションで可。アプリ本体のブランドカラーとの
   親和性を持たせると良い:
   - `seedColor`: `#1565C0`
   - 使用中のグラデーション例 (`lib/screens/level_select_screen.dart`):
     `#1565C0` → `#42A5F5`
   - 案A: 上記グラデーションを背景に、時計イラストを中央配置。
   - 案B: 元イラストの水色の空をそのまま活かしたフラットな水色背景。
6. 最終ファイルは `assets/icon/icon.png` を同名・同サイズで上書きする。

### 参考: 現在の `flutter_launcher_icons` 設定 (`pubspec.yaml`)

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/icon.png"
  web:
    generate: true
    image_path: "assets/icon/icon.png"
  windows:
    generate: true
    image_path: "assets/icon/icon.png"
  macos:
    generate: true
    image_path: "assets/icon/icon.png"
```

Android用の Adaptive Icon 専用設定(`adaptive_icon_background` /
`adaptive_icon_foreground`)は現状未設定。余裕があれば以下も検討すると、
将来的にさらにマスク耐性が上がる(前景は時計キャラクターのみの透過PNGを
別途用意し、背景色を指定する形):

```yaml
  adaptive_icon_background: "#1565C0"
  adaptive_icon_foreground: "assets/icon/icon_foreground.png"  # 透過PNG、セーフゾーン考慮
```

## 4. 画像差し替え後の作業手順

1. `assets/icon/icon.png` を新しい1024×1024画像に置き換える。
2. 全プラットフォームのアイコンを再生成する。
   - Flutter が使える環境:
     ```bash
     flutter pub get
     dart run flutter_launcher_icons
     ```
   - Flutter が使えない環境: 下記「5. 手動生成が必要な場合の対象ファイル一覧」
     を参照し、各サイズへ高品質リサンプル(Lanczos等)でリサイズして配布する。
3. 実機/エミュレータもしくはモックアップで、円形・角丸・しずく形など複数の
   ランチャーマスクを想定した見た目を確認する(特に Android)。

## 5. 手動生成が必要な場合の対象ファイル一覧

### Android (`android/app/src/main/res/`)
| ファイル | サイズ |
|---|---|
| mipmap-mdpi/ic_launcher.png | 48×48 |
| mipmap-hdpi/ic_launcher.png | 72×72 |
| mipmap-xhdpi/ic_launcher.png | 96×96 |
| mipmap-xxhdpi/ic_launcher.png | 144×144 |
| mipmap-xxxhdpi/ic_launcher.png | 192×192 |

(現状 RGBA。Adaptive Icon 用の `mipmap-anydpi-v26` は未設定)

### iOS (`ios/Runner/Assets.xcassets/AppIcon.appiconset/`)
| ファイル | サイズ |
|---|---|
| Icon-App-20x20@1x.png | 20×20 |
| Icon-App-20x20@2x.png | 40×40 |
| Icon-App-20x20@3x.png | 60×60 |
| Icon-App-29x29@1x.png | 29×29 |
| Icon-App-29x29@2x.png | 58×58 |
| Icon-App-29x29@3x.png | 87×87 |
| Icon-App-40x40@1x.png | 40×40 |
| Icon-App-40x40@2x.png | 80×80 |
| Icon-App-40x40@3x.png | 120×120 |
| Icon-App-50x50@1x.png | 50×50 |
| Icon-App-50x50@2x.png | 100×100 |
| Icon-App-57x57@1x.png | 57×57 |
| Icon-App-57x57@2x.png | 114×114 |
| Icon-App-60x60@2x.png | 120×120 |
| Icon-App-60x60@3x.png | 180×180 |
| Icon-App-72x72@1x.png | 72×72 |
| Icon-App-72x72@2x.png | 144×144 |
| Icon-App-76x76@1x.png | 76×76 |
| Icon-App-76x76@2x.png | 152×152 |
| Icon-App-83.5x83.5@2x.png | 167×167 |
| Icon-App-1024x1024@1x.png | 1024×1024 |

(App Store 提出用のためアルファチャンネルなしが望ましい)

### macOS (`macos/Runner/Assets.xcassets/AppIcon.appiconset/`)
| ファイル | サイズ |
|---|---|
| app_icon_16.png | 16×16 |
| app_icon_32.png | 32×32 |
| app_icon_64.png | 64×64 |
| app_icon_128.png | 128×128 |
| app_icon_256.png | 256×256 |
| app_icon_512.png | 512×512 |
| app_icon_1024.png | 1024×1024 |

### Web (`web/icons/`, `web/favicon.png`) — `docs/` 配下にも同一物のビルド済みコピーあり
| ファイル | サイズ | 備考 |
|---|---|---|
| favicon.png | 16×16 | |
| icons/Icon-192.png | 192×192 | |
| icons/Icon-512.png | 512×512 | |
| icons/Icon-maskable-192.png | 192×192 | maskable: セーフゾーンをさらに広く(直径80%以内にコンテンツ) |
| icons/Icon-maskable-512.png | 512×512 | 同上 |

### Windows
| ファイル | 備考 |
|---|---|
| windows/runner/resources/app_icon.ico | 複数解像度を含むICO(256×256などから生成) |

## 6. 元画像

現在の `assets/icon/icon.png` は変更していません(このドキュメント作成のみ)。
新しい画像が用意でき次第、本ファイルを差し替えて上記手順で再生成してください。
