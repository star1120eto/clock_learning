# App Store 公開 残作業チェックリスト

Apple Developer Program 登録完了時点（2026-07）での、iOS 版 App Store 公開までの残作業一覧。
調査対象コミット: `1f5d02e`（main）

優先度の凡例:
- 🔴 **ブロッカー** … これが未対応だと提出できない / ほぼ確実にリジェクトされる
- 🟡 **要対応** … 提出自体は可能だが、審査でのリジェクトリスクが高い
- 🟢 **推奨** … 品質・体験の改善。初回リリース後でも可

---

## A. リポジトリ内のコード / プロジェクト設定

### A-1. 🔴 Bundle Identifier が `com.example.*` のまま

| 箇所 | 現在の値 |
|------|---------|
| `ios/Runner.xcodeproj/project.pbxproj` (3箇所) | `com.example.clockLearning` |
| 同上 RunnerTests (3箇所) | `com.example.clockLearning.RunnerTests` |
| `android/app/build.gradle.kts` `namespace` / `applicationId` | `com.example.clock_learning` |

`com.example.*` は App Store Connect に登録できない。所有ドメインを逆順にした一意な ID
（例: `jp.<yourdomain>.clocklearning`）に変更し、**App Store Connect で同じ ID の App を作成**する。

> ⚠️ Bundle ID は登録後に変更できない。App Store Connect で App レコードを作る前に確定させること。
> Android の `applicationId` も同時に決めておく（Play 公開時に同じく変更不可）。

### A-2. 🔴 署名設定（Team / Provisioning Profile）が未設定

`project.pbxproj` に `DEVELOPMENT_TEAM` がなく、`CODE_SIGN_IDENTITY[sdk=iphoneos*] = "iPhone Developer"`（旧表記）のまま。

- Xcode → Runner target → Signing & Capabilities で Team を選択し、Automatically manage signing を有効化
- Capability に **In-App Purchase** を追加（`Runner.entitlements` が未生成のため、追加時に新規作成される）
- `ios/Runner/*.entitlements` がリポジトリに存在しないので、生成されたらコミットする

### A-3. 🔴 プライバシーポリシー / 利用規約 URL が `https://example.com/*` のまま

```
lib/screens/paywall_screen.dart:9-10
lib/screens/settings_screen.dart:9-10
```

サブスク課金アプリでは App 内・App Store Connect の双方に実在する URL が必須。
定数が 2 ファイルに重複しているので、`lib/constants/legal_urls.dart` 等に集約するのが望ましい。

### A-4. 🔴 プライバシーマニフェスト `PrivacyInfo.xcprivacy` が無い

`ios/` 配下に `.xcprivacy` が 1 つも存在しない。2024 年 5 月以降、
`UserDefaults` API（`shared_preferences` が使用）を含むアプリは
**Required Reason API の宣言が必須**で、無いと App Store Connect のアップロード時に警告〜拒否される。

作成が必要な内容（本アプリの実態に基づく）:

| 項目 | 宣言内容 |
|------|---------|
| `NSPrivacyTracking` | `false`（トラッキングなし） |
| `NSPrivacyTrackingDomains` | 空配列 |
| `NSPrivacyCollectedDataTypes` | 空配列（サーバー送信なし・端末内保存のみ） |
| `NSPrivacyAccessedAPITypes` | `NSPrivacyAccessedAPICategoryUserDefaults` / reason `CA92.1` |

配置先: `ios/Runner/PrivacyInfo.xcprivacy` を作成し、Xcode で Runner target の
Copy Bundle Resources に追加する。

### A-5. 🟡 Info.plist の不足項目

`ios/Runner/Info.plist` に以下が無い:

| キー | 必要な理由 |
|------|-----------|
| `ITSAppUsesNonExemptEncryption` = `false` | 無い場合、ビルドごとに輸出コンプライアンス質問への回答を手動で求められる |
| `CFBundleLocalizations` = `["ja"]` / `CFBundleDevelopmentRegion` | UI が全て日本語。開発言語が en のままだと審査時の想定言語と食い違う |

また整合性の問題:

- `CFBundleDisplayName` が英語の `Clock Learning`、`CFBundleName` が `clock_learning` だが、
  アプリ内タイトルは `とけいがくしゅう`（`lib/main.dart:50`）。ホーム画面の表示名を日本語にするか統一する
- `UISupportedInterfaceOrientations` に landscape が含まれるが、
  `lib/main.dart:17-20` で portrait 固定している。Info.plist 側も portrait のみに揃える
  （揃えない場合、iPad で横向き表示の検証を求められる可能性あり）

### A-6. 🟡 iPad 対応の扱いを決める

`TARGETED_DEVICE_FAMILY = "1,2"`（iPhone + iPad）のまま。iPad 対応を維持するなら
**13インチ iPad のスクリーンショットが必須**、かつ iPad 実機/シミュレータでの
レイアウト崩れ確認が必要。初回リリースを軽くするなら `1`（iPhone のみ）に変更する。

### A-7. 🟡 キッズカテゴリを選ぶ場合はペアレンタルゲートが必須

`lib/` 内に保護者確認（ペアレンタルゲート）の実装が無い。
未就学〜低学年向けの本アプリを **キッズカテゴリ**で出す場合、Apple は以下を要求する:

- 購入フロー（`PaywallScreen`）へ進む前に、子どもが突破できない年齢確認ゲート
- 外部リンク（プライバシーポリシー・利用規約の `launchUrl`）を開く前にも同じゲート
- サードパーティ解析・広告 SDK の不使用（現状 未使用なのでOK）

キッズカテゴリを選ばない（「教育」カテゴリ + 年齢制限 4+）場合は必須ではないが、
子ども向けを謳う以上、課金導線へのゲートは実装しておくのが安全。

**カテゴリ選択は先に決めること**（審査基準そのものが変わるため）。

### A-8. 🟡 サブスクリプション表示情報の不足

`lib/screens/paywall_screen.dart` は Restore ボタン・法的リンク・自動更新の説明文まで実装済みで良好。
ただし App Store Review Guideline 3.1.2 が要求する以下が不足:

- **サブスクリプションの期間**（月額/年額）が明示されていない。`ProductDetails.title` に依存しており、
  App Store Connect の登録名次第では期間が表示されない（`_PriceCard`、`paywall_screen.dart:429-447`）
- **単位あたりの価格**（年額プランの「1か月あたり◯円」等）は必須ではないが「おとく！」バッジを
  出すなら根拠として併記が望ましい
- 無料体験について「無料体験期間終了後、自動的に更新されます」と固定文言で書いているが
  （`paywall_screen.dart:118-121`）、**App Store Connect で無料体験（Introductory Offer）を
  設定しない場合は虚偽表示になる**。体験を設定するか、文言を修正するかを揃える

### A-9. 🟡 レシート検証がローカルのみ

`lib/services/subscription_service.dart` は購入完了イベントを受けて
`SharedPreferences` に `is_premium` を保存するだけで、レシート検証を行っていない。

- 審査は通る（Apple は必須要件としていない）が、端末側改ざんで有料機能が解放される
- サブスクの**期限切れ・解約後も `is_premium` が `true` のまま**になる構造的な問題がある
  （`restorePurchases()` は復元イベントで true にするだけで、false に戻す経路が無い）

初回リリースを優先するなら許容範囲だが、少なくとも「解約後に権利が戻らない」点は
既知の問題として認識しておくこと。将来的には StoreKit 2 / サーバー側検証への移行を推奨。

### A-10. 🟢 音声アセットが空

`assets/audio/` は `.gitkeep` のみで、`audio_service.dart` が参照する `audio/correct.ogg` 等が存在しない。
`try/catch` で握り潰しているためクラッシュはしないが、
**設定画面に「おとをならす」トグルがあるのに音が一切鳴らない**状態。
機能が動作しないことをリジェクト理由にされ得る（Guideline 2.1）ので、
音源を追加するか、トグルを一旦隠すかのどちらかを行う。
`assets/animations/` も同様に空（Lottie 未使用なら `pubspec.yaml` の依存削除も検討）。

### A-11. 🟢 起動画面が Flutter デフォルト

`ios/Runner/Assets.xcassets/LaunchImage.imageset/` はテンプレートのままで、
`README.md` も残っている。ブランド感のある起動画面に差し替えると審査官の印象が良い。

### A-12. 🟢 Web 版メタデータがテンプレートのまま

`web/index.html` の `description` が `A new Flutter project.`、
`web/manifest.json` の `name` が `clock_learning`。
App Store 提出には直接関係しないが、公開中の GitHub Pages 版の見え方に影響する。

### A-13. 🟢 バージョン番号

`pubspec.yaml`: `version: 1.1.0+2`。初回提出時に build number が重複しないよう管理する
（再提出のたびに `+N` をインクリメント）。

---

## B. 外部で用意が必要なもの（リポジトリ外）

### B-1. 🔴 プライバシーポリシーの作成・公開

必須。子ども向けアプリなので以下に言及すること:

- 収集する個人情報は無い（学習進捗は端末内 `SharedPreferences` のみに保存、外部送信なし）
- 課金は Apple / Google 経由で、開発者は決済情報を取得しない
- 第三者への提供・解析ツールの使用が無いこと
- 問い合わせ先メールアドレス
- COPPA / 日本の個人情報保護法への対応方針

公開先は GitHub Pages（`docs/` を既に gh-pages 運用しているので同じドメインに置ける）で十分。

### B-2. 🔴 利用規約の作成・公開

サブスクリプション条件（自動更新、解約方法、返金は Apple の規定に従う旨）を含める。

### B-3. 🔴 サポート URL / マーケティング URL

App Store Connect の必須項目。問い合わせ手段が分かるページを用意する
（GitHub Pages の 1 ページで、サポート窓口 + FAQ で可）。

### B-4. 🔴 有料 App 契約（Paid Applications Agreement）の締結

App Store Connect → ビジネス で以下を完了しないと、**課金アイテムが審査に出せない**:

- 有料 App 契約に同意
- 銀行口座情報の登録
- 税務情報（日本の居住者情報 / W-8BEN 等）の提出

反映まで日数がかかることがあるため、**最優先で着手すべき項目**。

### B-5. 🔴 スクリーンショット

必須サイズ:

| デバイス | 必要枚数 |
|---------|---------|
| iPhone 6.9インチ（またはApple指定の最新必須サイズ） | 最低 1、推奨 3〜5 |
| iPad 13インチ | iPad 対応を維持する場合のみ必須 |

ホーム / レベル選択 / 時計操作 / 結果・バッジ / ペイウォール あたりが候補。

### B-6. 🟡 App アイコン 1024×1024

`ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png` は
`flutter_launcher_icons` により生成済み。**アルファチャンネルが含まれていると提出時に弾かれる**ため、
`assets/icon/icon.png` から生成された 1024px 画像が不透明であることを確認する。

---

## C. App Store Connect 側の作業

### C-1. 🔴 App レコードの作成

- プラットフォーム: iOS
- 名前（30文字以内）: 例「とけいがくしゅう」— **App Store 全体で一意**である必要あり
- プライマリ言語: 日本語
- Bundle ID: A-1 で確定したもの
- SKU: 任意の管理用文字列

### C-2. 🔴 サブスクリプションの登録

`lib/services/subscription_service.dart:7-8` で参照している Product ID を
**完全一致**で登録する:

| 定数 | Product ID | 種別 |
|------|-----------|------|
| `kMonthlySubId` | `clock_learning_premium_monthly` | 自動更新サブスクリプション（月） |
| `kYearlySubId` | `clock_learning_premium_yearly` | 自動更新サブスクリプション（年） |

必要作業:

1. サブスクリプショングループを 1 つ作成し、両プランを同じグループに入れる（プラン変更のため）
2. 各プランの**表示名・説明**を日本語で登録（`_PriceCard` がこの `title` を表示する → A-8 参照）
3. 価格の設定
4. 無料体験（Introductory Offer）を使うかを決定 → A-8 の文言と揃える
5. **審査用スクリーンショット**を各サブスクリプションにアップロード（未設定だと審査が始まらない）
6. サブスクリプション自体を「審査に提出」— アプリ本体のビルドと同時に提出する

### C-3. 🔴 App プライバシー（Nutrition Label）の回答

本アプリの実態: 外部サーバー送信なし、解析 SDK なし → **「データを収集していません」** で回答可能。
A-4 の `PrivacyInfo.xcprivacy` の内容と矛盾しないようにする。

### C-4. 🔴 年齢別レーティングの回答

暴力・成人向け要素なし → 4+ になる想定。
**「App 内課金あり」のチェックを忘れずに**。

### C-5. 🟡 カテゴリの選択

- 第一候補: 教育（Education）
- キッズカテゴリを選ぶ場合は A-7 のペアレンタルゲートが前提

### C-6. 🟡 審査メモ（App Review Information）

- デモアカウント: 不要（ログイン機能なし）と明記
- **課金の確認方法**: 「レベル選択画面の『ふつう』『むずかしい』をタップするとペイウォールが開きます」
  のように、審査官が課金導線に到達する手順を具体的に書く。書かないと
  「IAP が見つからない」で差し戻されるケースが多い
- 端末内にのみデータを保存し、外部通信は課金処理のみである旨

### C-7. 🟢 その他の申告

- 輸出コンプライアンス: 暗号化の使用なし（A-5 の `ITSAppUsesNonExemptEncryption` で自動化可）
- アカウント削除要件: アカウント登録機能が無いため **対象外**
- 広告識別子（IDFA）: 使用なし

---

## D. ビルドと提出

### D-1. 🔴 macOS + Xcode 環境

iOS ビルドには macOS 実機が必須（現在の開発環境が Linux のみなら要確保）。
App Store は**最新の Xcode SDK でビルドされたバイナリ**のみ受け付けるため、Xcode は最新安定版を使う。

### D-2. 🟡 Podfile のプラットフォーム指定

`ios/Podfile:2` の `platform :ios, '13.0'` がコメントアウトされたまま。
`IPHONEOS_DEPLOYMENT_TARGET = 13.0` と揃うよう有効化しておくと、
Pod 側の warning とビルド失敗を防げる。

### D-3. リリースビルド手順

```bash
flutter clean
flutter pub get
cd ios && pod install --repo-update && cd ..
flutter build ipa --release
```

生成物 `build/ios/ipa/*.ipa` を Xcode Organizer / Transporter でアップロード。

### D-4. 🔴 Sandbox 環境での課金テスト

App Store Connect → ユーザーとアクセス → Sandbox テスターを作成し、実機で以下を確認:

- [ ] 月額・年額の商品情報が取得できる（`queryProductDetails` の `notFoundIDs` が空）
- [ ] 購入完了でプレミアム機能が解放される
- [ ] アプリ再インストール後に「こうにゅうをふっげんする」で復元できる
- [ ] 購入キャンセル時にエラー表示が適切
- [ ] 機内モード時に「ストアに接続できません」が表示される

> ⚠️ `notFoundIDs` に商品が入る状態のまま提出すると、審査官の画面で価格が出ず
> **確実にリジェクト**される。C-2 の登録完了後、必ず実機で確認すること。

### D-5. 🟡 TestFlight での動作確認

内部テスターで 1 ラウンド確認してから審査提出するのが安全。

---

## E. 推奨する着手順序

```
1. B-4 有料App契約 + 銀行/税務情報       ← 反映に日数がかかるので最初に
2. A-1 Bundle ID 確定
3. C-1 App レコード作成
4. B-1/B-2/B-3 法務ページ公開 → A-3 URL 差し替え
5. A-4 PrivacyInfo.xcprivacy 追加 / A-5 Info.plist 整備
6. A-7 カテゴリ決定（キッズなら ペアレンタルゲート実装）
7. A-8 ペイウォール文言・期間表示の修正
8. C-2 サブスクリプション登録（Product ID 完全一致）
9. A-2 署名設定 → D-3 ビルド
10. D-4 Sandbox 課金テスト
11. B-5 スクリーンショット撮影
12. C-3〜C-6 メタデータ入力 → 審査提出
```

---

## F. リポジトリ内で今すぐ着手できるタスク（サマリ）

| # | 対象ファイル | 内容 | 優先度 |
|---|-------------|------|--------|
| 1 | `ios/Runner.xcodeproj/project.pbxproj`, `android/app/build.gradle.kts` | Bundle ID / applicationId の変更 | 🔴 |
| 2 | `ios/Runner/PrivacyInfo.xcprivacy`（新規） | プライバシーマニフェスト追加 | 🔴 |
| 3 | `lib/constants/legal_urls.dart`（新規）, `paywall_screen.dart`, `settings_screen.dart` | 法的 URL の集約と実 URL 化 | 🔴 |
| 4 | `ios/Runner/Info.plist` | `ITSAppUsesNonExemptEncryption` / `CFBundleLocalizations` / 向き整合 / 表示名 | 🟡 |
| 5 | `lib/screens/paywall_screen.dart` | 期間表示の明示、無料体験文言の整合 | 🟡 |
| 6 | `lib/widgets/`（新規） | ペアレンタルゲート（キッズカテゴリ採用時） | 🟡 |
| 7 | `ios/Podfile` | `platform :ios, '13.0'` を有効化 | 🟡 |
| 8 | `lib/services/subscription_service.dart` | 解約後に `is_premium` が戻らない問題への対応 | 🟢 |
| 9 | `assets/audio/` | 音源追加、または音声トグルの非表示化 | 🟢 |
| 10 | `web/index.html`, `web/manifest.json` | メタデータのテンプレート値を修正 | 🟢 |
