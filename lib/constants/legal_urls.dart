/// 法的情報の公開 URL
///
/// App Store / Google Play の審査要件により、プライバシーポリシーと利用規約は
/// アプリ内から到達できる実在の URL である必要がある。
/// 実体は `web/` 配下の静的ページで、GitHub Pages に自動デプロイされる
/// （.github/workflows/deploy-web.yml）。
///
/// 独自ドメインを取得した場合は、以下の [kSiteBaseUrl] のみ差し替えればよい。
library;

/// 公開サイトのベース URL（末尾スラッシュなし）
const String kSiteBaseUrl = 'https://star1120eto.github.io/clock_learning';

/// プライバシーポリシー
const String kPrivacyPolicyUrl = '$kSiteBaseUrl/privacy.html';

/// 利用規約
const String kTermsOfServiceUrl = '$kSiteBaseUrl/terms.html';

/// サポートページ（App Store Connect のサポート URL にも使用する）
const String kSupportUrl = '$kSiteBaseUrl/support.html';
