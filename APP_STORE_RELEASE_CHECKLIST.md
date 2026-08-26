# App Store 公開 残作業チェックリスト

Apple Developer Program 登録完了時点（2026-07）での、iOS 版 App Store 公開までの残作業一覧。

- 調査対象コミット: `1f5d02e`（main）
- 方針決定済み: **教育カテゴリ（4+）＋ペアレンタルゲート実装**で公開する
- Bundle ID: **`tech.starfy.clocklearning`** に確定済み（所有ドメイン `starfy.tech` に基づく）

凡例:
- 🔴 **ブロッカー** … 未対応だと提出できない / ほぼ確実にリジェクトされる
- 🟡 **要対応** … 提出自体は可能だが、審査でのリジェクトリスクが高い
- 🟢 **推奨** … 品質・体験の改善。初回リリース後でも可
- ✅ **対応済み** … このリポジトリで対応完了

---

## 🚩 現在の状況（2026-08-18 時点）

> ### 📋 残作業はすべて GitHub Issue に起票済み → **#53（トラッキング Issue）** を参照
>
> 本ファイルは各項目の背景・調査結果を残すためのドキュメント。
> **進捗管理は Issue 側で行う。** 各セクション見出しの直下に対応 Issue 番号を記載している。

**作業ブランチ**: `claude/clock-learning-app-store-l1yaaa`
**Xcode 作業マシン**: `starfy@YutanoMac-mini`（macOS 26.5 / Xcode 26.6 / iOS 26.5 SDK）

> ⚠️ ローカルでコミットする際は新しいブランチを切らず、
> `claude/clock-learning-app-store-l1yaaa` を直接使うこと。
> （`git checkout claude/clock-learning-app-store-l1yaaa && git pull`）

### 直近で完了したこと

- **C-1（App レコード作成）**: App Store Connect 上に「とけいがくしゅう」v1.0（提出準備中）
- **C-2（サブスクリプション登録）**: 月額 ¥480 / 年額 ¥4,800 とも「審査準備完了」。
  価格・ローカリゼーション・審査用スクリーンショットをすべて設定済み
- **macOS 環境構築**: Xcode ライセンス同意 → iOS シミュレータランタイム導入 → CocoaPods 導入まで完了。
  シミュレータで実際にアプリを起動し、ペアレンタルゲート → ペイウォールまで到達。
  月額・年額とも `queryProductDetails` で取得できることを確認済み
- **A-2（署名設定）**: Team（`A5TL863KQZ`）選択・StoreKit.framework リンク・
  In-App Purchase capability 追加まで完了（`project.pbxproj` にコミット済み）

### 次にやること

**#53 の「推奨する着手順序」を参照。** 先に着手すべきものだけ挙げると:

1. **#36 有料 App 契約** — Apple 側の処理待ちで日数がかかるため最優先で状況確認
2. **#47 法務 URL の到達確認** — ブラウザで開くだけ、すぐ終わる
3. **#45 iPad 対応の可否** — #37 のスクリーンショット作業量が変わるので先に決める

### 引き継ぎ時のメモ

- Xcode・シミュレータ操作はユーザー（starfy）の Mac 上で行われる。
  ローカルセッションなら Bash ツールで直接コマンド実行・ファイル確認ができる
- App Store Connect（ブラウザ）の操作は代行できないため、
  画面のスクリーンショットを貼ってもらいながら進める運用が必要

---

## A. リポジトリ内のコード / プロジェクト設定

### A-1. ✅ Bundle Identifier

所有ドメイン `starfy.tech` に基づき **`tech.starfy.clocklearning`** に確定・変更した。

| 箇所 | 変更後 |
|------|--------|
| `ios/Runner.xcodeproj/project.pbxproj`（3箇所） | `tech.starfy.clocklearning` |
| 同上 RunnerTests（3箇所） | `tech.starfy.clocklearning.RunnerTests` |
| `android/app/build.gradle.kts` `namespace` / `applicationId` | `tech.starfy.clocklearning` |
| `android/app/src/main/kotlin/tech/starfy/clocklearning/MainActivity.kt` | パッケージ宣言とディレクトリを移動 |
| `android/app/src/main/AndroidManifest.xml` `android:label` | `とけいがくしゅう`（iOS の表示名と統一） |

> ⚠️ **App Store Connect / Google Play Console に登録した後は変更できない。**
> App レコード作成時はこの ID を使うこと。

macOS / Linux / Windows の各 runner 設定には `com.example` が残っているが、
これらのプラットフォームは配布対象外のため変更していない。

法務ページを独自ドメインに移す場合は `lib/constants/legal_urls.dart` の
`kSiteBaseUrl` を差し替える（例: `clock.starfy.tech` を GitHub Pages に CNAME で向ける）。
Bundle ID とページの URL は一致している必要はないため、**急ぐ作業ではない**。

### A-2. 🟡 一部対応 — 署名設定（Team / Provisioning Profile）

> 📋 Issue: #35

macOS + Xcode で以下まで完了:

- Signing & Capabilities で Team（`Yuta Hoshino` / Team ID `A5TL863KQZ`）を選択し、
  Automatically manage signing を有効化 → `project.pbxproj` に `DEVELOPMENT_TEAM = A5TL863KQZ` が反映済み
- StoreKit.framework をリンク済み
- Capability に **In-App Purchase** を追加済み

> ⚠️ **訂正**: 本ファイルの旧版には「In-App Purchase を追加すると `Runner.entitlements` が
> 新規生成されるのでコミットする」と書かれていたが、**これは誤り**。
> In-App Purchase は Push Notifications や App Groups と異なり **entitlement キーを持たない**。
> capability は App ID（developer.apple.com）側で有効化されるだけで、Xcode は
> entitlements ファイルを生成しない。iOS 側に entitlements が存在しないのは正常な状態。

残作業:
- 実機未登録のため「Communication with Apple failed」「No profiles for
  'tech.starfy.clocklearning' were found」という警告が出る。これは **Development** プロファイル
  生成用の実機がチームに未登録なのが原因で、シミュレータ実行には影響しない。
  App Store 配布は Distribution プロファイルを使うためアーカイブは通る見込み
- `flutter build ipa --release` が署名エラーなく通ることを実際に確認する（#35）

### A-3. ✅ プライバシーポリシー / 利用規約 URL

`https://example.com/*` のプレースホルダを廃止し、`lib/constants/legal_urls.dart` に集約した。

| 定数 | URL |
|------|-----|
| `kPrivacyPolicyUrl` | `https://star1120eto.github.io/clock_learning/privacy.html` |
| `kTermsOfServiceUrl` | `https://star1120eto.github.io/clock_learning/terms.html` |
| `kSupportUrl` | `https://star1120eto.github.io/clock_learning/support.html` |

独自ドメインへ移行する場合は `kSiteBaseUrl` の 1 行のみ差し替えればよい。
`settings_screen.dart` にはサポートページへの導線も追加した。

### A-4. ✅ プライバシーマニフェスト `PrivacyInfo.xcprivacy`

`ios/Runner/PrivacyInfo.xcprivacy` を作成し、`project.pbxproj` の
Runner グループと Copy Bundle Resources に登録済み。

| 項目 | 宣言内容 |
|------|---------|
| `NSPrivacyTracking` | `false` |
| `NSPrivacyTrackingDomains` | 空配列 |
| `NSPrivacyCollectedDataTypes` | 空配列（外部送信なし） |
| `NSPrivacyAccessedAPITypes` | `NSPrivacyAccessedAPICategoryUserDefaults` / reason `CA92.1` |

`CA92.1` は「自アプリからのみアクセスされる情報の読み書き」で、
`shared_preferences` の用途（学習進捗・設定・購入状態の保存）に合致する。

> 📌 Xcode で開いた際、Runner target の Build Phases → Copy Bundle Resources に
> `PrivacyInfo.xcprivacy` が入っていることを一度目視確認すること（pbxproj を手書きで編集したため）。

### A-5. ✅ Info.plist の整備

- `ITSAppUsesNonExemptEncryption` = `false` を追加（提出ごとの輸出コンプライアンス質問を省略）
- `CFBundleDevelopmentRegion` を `ja` に変更し、`CFBundleLocalizations` = `["ja"]` を追加
- `CFBundleDisplayName` を `Clock Learning` → `とけいがくしゅう` に変更（アプリ内タイトルと統一）
- `UISupportedInterfaceOrientations`（iPhone / iPad とも）を縦向きのみに変更し、
  `lib/main.dart` の `setPreferredOrientations` と整合させた

### A-6. 🟡 iPad 対応の扱いを決める

> 📋 Issue: #45

`TARGETED_DEVICE_FAMILY = "1,2"`（iPhone + iPad）のまま**変更していない**。
維持する場合は **13インチ iPad のスクリーンショットが必須**で、
iPad 実機/シミュレータでのレイアウト確認も必要。
初回リリースを軽くするなら `1`（iPhone のみ）に変更する。

### A-7. ✅ ペアレンタルゲート（保護者確認）

`lib/widgets/parental_gate.dart` を追加。教育カテゴリでは必須要件ではないが、
子ども向けアプリとして課金導線を保護するために実装した。

仕様:
- 「NN × N = ?」（11〜29 × 3〜9）を**選択式ではなく数値入力**で回答させる
- 説明文・ボタンをすべて漢字表記にし、対象年齢（4〜8歳）が読めないようにする
- 誤答は 3 回まで。超えると閉じる。ダイアログ外タップでは閉じない

適用箇所:

| 画面 | 操作 |
|------|------|
| `level_select_screen.dart` | ロック中レベルのタップ → ペイウォール |
| `level_select_screen.dart` | プレミアム案内バナーのタップ → ペイウォール |
| `settings_screen.dart` | 「プレミアムにアップグレード」→ ペイウォール |
| `settings_screen.dart` | プライバシーポリシー / 利用規約 / サポートの外部リンク |

ホーム画面右上の星アイコン（`home_screen.dart`）は**プレミアム加入者にのみ表示**され、
遷移先も加入済み画面で購入操作がないため、ゲートは適用していない。

ペイウォール内の法的リンクは、画面到達時点でゲートを通過済みのため再確認しない。

テスト: `test/widgets/parental_gate_test.dart`（正解・キャンセル・誤答・回数超過・
バリアタップの 5 ケース）

### A-8. ✅ サブスクリプション表示情報（Guideline 3.1.2）

`lib/screens/paywall_screen.dart` を修正:

- **期間を App Store Connect の登録名に依存させない**。`ProductDetails.title` の表示をやめ、
  アプリ側が持つ「年額プラン / 月額プラン」＋「1年ごとに自動更新 / 1か月ごとに自動更新」を表示する
- 年額プランに「1か月あたり ◯◯ 相当」を併記（`rawPrice / 12`）。「おとく！」バッジの根拠になる
- **無料体験の記述を削除**。旧文言は「無料体験期間終了後、自動的に更新されます」と
  無条件に書いていたため、Introductory Offer を設定しない場合は虚偽表示になっていた。
  自動更新・請求タイミング・解約手順（iOS / Android 別）を記載する文言に差し替えた

> 📌 App Store Connect で無料体験を設定する場合は、この文言に体験期間の説明を戻すこと。

### A-9. 🟡 一部対応 — レシート検証がローカルのみ

> 📋 Issue: #50

`lib/services/subscription_service.dart` は購入イベントを受けて
`SharedPreferences` に `is_premium` を保存するだけで、レシート検証を行っていない。

対応した点:
- ユーザー操作による `restorePurchases()` で対象商品が 1 件も復元されなかった場合、
  `is_premium` を `false` に戻すようにした（従来は `true` に上げる経路しかなかった）
- 通信エラー時は権利を取り消さない（有料ユーザーの誤締め出しを防ぐ）

残る制約:
- StoreKit 1 の復元は失効済みトランザクションも返し得るため、**解約・期限切れを確実には検知できない**
- 起動時の自動復元では権利を取り消さない（オフライン起動での誤判定を避けるため）
- 端末側の改ざんで有料機能を解放される余地がある

正確な有効期限判定にはサーバー側レシート検証 / StoreKit 2 への移行が必要。
審査は現状でも通るため、初回リリース後の課題とする。

### A-10. 🟢 音声アセットが空（未対応）

> 📋 Issue: #46

`assets/audio/` は `.gitkeep` のみで、`audio_service.dart` が参照する
`audio/correct.ogg` 等が存在しない。`try/catch` で握り潰しているためクラッシュはしないが、
**設定画面に「おとをならす」トグルがあるのに音が一切鳴らない**。
機能が動作しないことをリジェクト理由にされ得る（Guideline 2.1）。

音源そのものは自動生成できないため未対応。以下のいずれかを選ぶ:
1. 効果音（正解 / 不正解 / バッジ獲得）を用意して `assets/audio/` に配置する
2. 音源が用意できるまで、設定画面の音声トグルを非表示にする

`assets/animations/` も空。Lottie を使わないなら `pubspec.yaml` から
`lottie` 依存を削除するとバイナリサイズが減る。

### A-11. 🟢 起動画面が Flutter デフォルト（未対応）

> 📋 Issue: #51

`ios/Runner/Assets.xcassets/LaunchImage.imageset/` はテンプレートのまま。
画像素材が必要なため未対応。

### A-12. ✅ Web 版メタデータ

- `web/index.html`: `lang="ja"`、タイトル、description、`apple-mobile-web-app-title` を実際の内容に変更
- `web/manifest.json`: `name` / `short_name` / `description` を日本語化し、
  テーマカラーをアプリのシード色 `#1565C0` に統一

### A-13. 🟢 バージョン番号

`pubspec.yaml`: `version: 1.1.0+2`。初回提出時に build number が重複しないよう、
再提出のたびに `+N` をインクリメントする。

---

## B. 外部で用意が必要なもの

### B-1〜B-3. ✅ 法務・サポートページを作成

`web/` 配下に作成した。`flutter build web` の出力に含まれ、
`.github/workflows/deploy-web.yml` により main への push で GitHub Pages に自動デプロイされる。

| ファイル | 公開 URL | 内容 |
|---------|---------|------|
| `web/privacy.html` | `/privacy.html` | 個人情報を収集しないこと、端末内保存の内容、解析・広告の不使用、課金の扱い、COPPA / 個人情報保護法への言及 |
| `web/terms.html` | `/terms.html` | 全12条。サブスクの自動更新条件、解約手順、返金、禁止事項、免責、準拠法 |
| `web/support.html` | `/support.html` | FAQ 8項目（対象年齢、無料範囲、解約、復元、データ引き継ぎ、音、課金防止、広告） |

問い合わせ先は 3 ファイルとも `yuutec171@gmail.com`（アプリ専用アドレス）に設定済み。

App Store Connect 側でも、以下に同じアドレス / URL を設定する:
- サポート URL → `https://star1120eto.github.io/clock_learning/support.html`
- App Review Information の連絡先
- EU デジタルサービス法の事業者情報（EU 圏では製品ページ上で**公開表示**される）

デプロイ後、3つの URL が 200 で開けることを必ず確認する（リンク切れは審査でのリジェクト理由になる）。

### B-4. 🟡 進行中 — 有料 App 契約（Paid Applications Agreement）

> 📋 Issue: #36

課金アイテムを審査に出すには、この契約が「有効」になっている必要がある。
2026年8月4日時点の状況:

| 項目 | 状態 |
|------|------|
| 無料アプリ契約 | ✅ 有効 |
| 有料アプリ契約 | 🟡 ユーザ情報を保留中 |
| 銀行口座（ゆうちょ銀行） | 🟡 処理中（Apple 側の検証待ち・操作不要） |
| U.S. Form W-8BEN | ✅ 有効（第12条・0%・Income from the sale of applications で申請） |
| U.S. Certificate of Foreign Status | 🔴 税金情報が不足（「税金情報を追加」から入力が必要） |
| デジタルサービス法（EU DSA） | ✅ 有効 |

残作業は納税フォームの不足分の入力と、銀行口座の検証完了待ち。

> ゆうちょ銀行は通帳の記号・番号ではなく、他行振込用の店名（3桁）・預金種目・
> 口座番号（7桁）を登録する。検証がエラーになる場合はここを疑う。

### B-5. 🔴 スクリーンショット

> 📋 Issue: #37

| デバイス | 必要枚数 |
|---------|---------|
| iPhone 6.9インチ（またはApple指定の最新必須サイズ） | 最低 1、推奨 3〜5 |
| iPad 13インチ | iPad 対応を維持する場合のみ必須（A-6 参照） |

ホーム / レベル選択 / 時計操作 / 結果・バッジ / ペイウォール あたりが候補。

### B-6. ✅ App アイコン 1024×1024

`ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png` を検査し、
**アルファチャンネルを含まないこと（PNG colortype=2 / RGB、tRNS チャンクなし）を確認済み**。
提出時に弾かれる心配はない。

```console
$ python3 -c "import struct; d=open('ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png','rb').read(33); print(struct.unpack('>II',d[16:24]), 'colortype=', d[25])"
(1024, 1024) colortype= 2
```

---

## C. App Store Connect 側の作業

### C-1. 🔴 App レコードの作成

- プラットフォーム: iOS
- 名前（30文字以内）: 例「とけいがくしゅう」— **App Store 全体で一意**である必要あり
- プライマリ言語: 日本語
- Bundle ID: `tech.starfy.clocklearning`
- SKU: 任意の管理用文字列

### C-2. ✅ サブスクリプションの登録

`lib/services/subscription_service.dart:7-8` の Product ID と完全一致で登録済み。

| 定数 | Product ID | 種別 | 価格（日本） | ステータス |
|------|-----------|------|------|------|
| `kMonthlySubId` | `clock_learning_premium_monthly` | 自動更新サブスクリプション（月） | ¥480 | 審査準備完了 |
| `kYearlySubId` | `clock_learning_premium_yearly` | 自動更新サブスクリプション（年） | ¥4,800 | 審査準備完了 |

- サブスクリプショングループ「プレミアムプラン」（グループID: `22312547`）に両プランを登録
- グループ表示名（App Store のローカリゼーション）: 「とけいがくしゅう」（アプリ名を使用）
- 各プランの表示名・説明（日本語）、価格（日本 ¥480 / ¥4,800、他174地域は自動換算）を設定済み
- **無料体験（Introductory Offer）は使わない方針で確定** → A-8 の文言修正（無料体験の記述削除）はそのままで問題なし。コード変更不要
- 各プランに審査用スクリーンショットをアップロード済み（iOSシミュレータ + StoreKitで実際にペイウォールを表示して撮影）
- macOS実機でのシミュレータ動作確認により、月額・年額とも `queryProductDetails` で正しく取得できることを確認済み（`notFoundIDs` が空になることを確認）

残作業:
- サブスクリプション自体の「審査に提出」は、**アプリ本体のビルドと同時に行う**必要があるため（Apple仕様）、D-3のビルド提出時にまとめて行う

> アプリ側は期間表示を自前で持つようにしたため（A-8）、
> App Store Connect の登録名に「月額」等を含めなくても期間は正しく表示される。

> 📌 macOS側のセットアップ手順（今回新たに判明した実務メモ）:
> - `xcode-select -p` が `/Library/Developer/CommandLineTools` を指している場合、
>   `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer` で切り替えてから
>   `sudo xcodebuild -license accept` を実行する
> - iOSシミュレータランタイムが未インストールの場合は `xcodebuild -downloadPlatform iOS`
> - CocoaPods未インストールの場合は `brew install cocoapods`（Homebrewが無ければ `sudo gem install cocoapods`）
> - 上記を済ませれば `cd ios && pod install --repo-update && cd .. && flutter run -d "<シミュレータ名>"` でシミュレータ起動可能
> - シミュレータの Apple ID / ストア地域が日本以外だと、ペイウォールの価格は USD 等で表示される（バグではない。実機で日本のApple IDを使えば¥表示になる）

### C-3. 🔴 App プライバシー（Nutrition Label）の回答

> 📋 Issue: #38

外部サーバー送信なし、解析 SDK なし → **「データを収集していません」** で回答する。
`PrivacyInfo.xcprivacy`（A-4）および `web/privacy.html`（B-1）と矛盾させないこと。

### C-4. 🔴 年齢別レーティングの回答

> 📋 Issue: #39

暴力・成人向け要素なし → 4+ の想定。**「App 内課金あり」のチェックを忘れずに**。

### C-5. 🟡 カテゴリ

> 📋 Issue: #48

- プライマリ: 教育（Education）
- キッズカテゴリは選択しない（決定済み）。ペアレンタルゲートは実装済み（A-7）

### C-6. 🟡 審査メモ（App Review Information）

> 📋 Issue: #44

以下を必ず記載する:

- デモアカウント: 不要（ログイン機能なし）
- **課金の確認手順**: 「ホーム →『とけいをあわせる』→ ロックされた『ふつう』をタップ →
  保護者確認（表示された掛け算の答えを入力）→ 購入画面」。
  ペアレンタルゲートの存在と突破方法を書かないと、審査官が課金画面に到達できず差し戻される
- 端末内にのみデータを保存し、外部通信は課金処理のみである旨

### C-7. 🟢 その他の申告

> 📋 Issue: #48

- 輸出コンプライアンス: 暗号化の使用なし（A-5 で Info.plist に記載済み）
- アカウント削除要件: アカウント登録機能が無いため **対象外**
- 広告識別子（IDFA）: 使用なし

---

## D. ビルドと提出

### D-1. 🔴 macOS + Xcode 環境

iOS ビルドには macOS 実機が必須。App Store は**最新の Xcode SDK でビルドされたバイナリ**のみ
受け付けるため、Xcode は最新安定版を使う。

### D-2. ✅ Podfile のプラットフォーム指定

`ios/Podfile` の `platform :ios, '13.0'` を有効化し、
`IPHONEOS_DEPLOYMENT_TARGET = 13.0` と揃えた。

### D-3. リリースビルド手順

> 📋 Issue: #41

```bash
flutter clean
flutter pub get
cd ios && pod install --repo-update && cd ..
flutter build ipa --release
```

生成物 `build/ios/ipa/*.ipa` を Xcode Organizer / Transporter でアップロード。

### D-4. 🔴 Sandbox 環境での課金テスト

> 📋 Issue: #42

App Store Connect → ユーザーとアクセス → Sandbox テスターを作成し、実機で確認する:

- [ ] 月額・年額の商品情報が取得できる（`queryProductDetails` の `notFoundIDs` が空）
- [ ] ペイウォールに「年額プラン / 1年ごとに自動更新・1か月あたり◯◯相当」が正しく表示される
- [ ] 購入完了でプレミアム機能が解放される
- [ ] アプリ再インストール後に「こうにゅうをふくげんする」で復元できる
- [ ] **未購入の Sandbox アカウントで復元すると、プレミアム表示が解除される**（A-9 の変更点）
- [ ] 購入キャンセル時にエラー表示が適切
- [ ] 機内モード時に「ストアに接続できません」が表示される
- [ ] ペアレンタルゲートが正解でのみ突破でき、誤答 3 回で閉じる

> ⚠️ `notFoundIDs` に商品が入る状態のまま提出すると、審査官の画面で価格が出ず
> **確実にリジェクト**される。C-2 の登録完了後、必ず実機で確認すること。

### D-5. 🟡 TestFlight での動作確認

> 📋 Issue: #49

内部テスターで 1 ラウンド確認してから審査提出するのが安全。

---

## E. 推奨する着手順序

```
1. B-4 有料App契約 + 銀行/税務情報       ← 反映に日数がかかるので最初に
3. C-1 App レコード作成
4. B-1〜B-3 の連絡先メールを差し替え → main にマージして GitHub Pages を更新
                                       → 3つの URL が開けることを確認
5. A-6 iPad 対応の可否を決定
6. A-2 署名設定（macOS + Xcode）
7. C-2 サブスクリプション登録（Product ID 完全一致）
8. D-3 ビルド → D-4 Sandbox 課金テスト
9. B-5 スクリーンショット撮影
10. C-3〜C-6 メタデータ入力（審査メモにゲート突破手順を明記）→ 審査提出
```

---

## F. 対応状況サマリ

| # | 対象 | 内容 | 状態 |
|---|------|------|------|
| 1 | `project.pbxproj`, `build.gradle.kts` ほか | Bundle ID を `tech.starfy.clocklearning` に変更 | ✅ |
| 2 | `ios/Runner/PrivacyInfo.xcprivacy` | プライバシーマニフェスト追加 | ✅ |
| 3 | `lib/constants/legal_urls.dart` ほか | 法的 URL の集約と実 URL 化 | ✅ |
| 4 | `web/privacy.html` / `terms.html` / `support.html` | 法務・サポートページ作成 | ✅ 連絡先メールのみ要差し替え |
| 5 | `ios/Runner/Info.plist` | 暗号化申告・ローカライズ・表示名・向き | ✅ |
| 6 | `lib/widgets/parental_gate.dart` ほか | ペアレンタルゲート実装と適用 | ✅ |
| 7 | `lib/screens/paywall_screen.dart` | 期間表示の明示、無料体験文言の修正 | ✅ |
| 8 | `ios/Podfile` | `platform :ios, '13.0'` の有効化 | ✅ |
| 9 | `web/index.html`, `web/manifest.json` | メタデータの日本語化 | ✅ |
| 10 | `lib/services/subscription_service.dart` | 復元時に権利を取り消す経路を追加 | 🟡 一部（サーバー検証は未対応） |
| 11 | `assets/audio/` | 音源追加、または音声トグルの非表示化 | 🟢 未対応（素材が必要） |
| 12 | `ios/.../LaunchImage.imageset` | 起動画面の差し替え | 🟢 未対応（素材が必要） |
| 13 | `TARGETED_DEVICE_FAMILY` | iPad 対応の可否 | 🟡 判断待ち |
