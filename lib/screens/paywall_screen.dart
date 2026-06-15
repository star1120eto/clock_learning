import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:clock_learning/services/subscription_service.dart';

// 本番環境では実際のURLに変更すること
const String _kPrivacyPolicyUrl = 'https://example.com/privacy';
const String _kTermsOfServiceUrl = 'https://example.com/terms';

/// サブスクリプション購入画面（ペイウォール）
/// Apple審査要件: Restore Purchases ボタン・プライバシーポリシー・利用規約が必須
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionService>(
      builder: (context, service, _) {
        if (service.isPremium) {
          return _AlreadyPremiumBody(onClose: () => Navigator.pop(context));
        }
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: const Color(0xFF1565C0),
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 40),
                        Icon(Icons.stars, color: Colors.amber, size: 64),
                        SizedBox(height: 12),
                        Text(
                          'プレミアムプラン',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'すべてのレベルにちょうせん！',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 特典リスト
                      _buildFeatureList(),
                      const SizedBox(height: 32),
                      // 価格カード
                      if (service.isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (!service.storeAvailable)
                        _buildStoreUnavailableMessage()
                      else
                        _buildPriceSection(context, service),
                      const SizedBox(height: 16),
                      // エラーメッセージ
                      if (service.purchaseError != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            service.purchaseError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      // 購入復元ボタン（Apple審査要件：必須）
                      TextButton(
                        onPressed: () => _onRestoreTap(context, service),
                        child: const Text(
                          'こうにゅうをふっげんする',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      // 法的リンク（App Store / Google Play 要件）
                      _buildLegalLinks(),
                      const SizedBox(height: 16),
                      // サブスクリプション説明文（Apple審査要件）
                      const Text(
                        'サブスクリプションはApple ID / Google アカウントに課金されます。'
                        '無料体験期間終了後、自動的に更新されます。'
                        '購読の管理・キャンセルはデバイスの設定から行えます。',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureList() {
    const features = [
      _FeatureItem(
        icon: Icons.lock_open,
        color: Color(0xFF388E3C),
        label: 'ふつうレベル かいきん',
        desc: '5ふんごとにじかんをあわせる',
      ),
      _FeatureItem(
        icon: Icons.emoji_events,
        color: Color(0xFFE65100),
        label: 'むずかしいレベル かいきん',
        desc: '1ふんごとのせいかくなじかん',
      ),
      _FeatureItem(
        icon: Icons.bar_chart,
        color: Color(0xFF1565C0),
        label: 'くわしいしんちょく',
        desc: 'レベルべつのせいかいりつをかくにん',
      ),
      _FeatureItem(
        icon: Icons.star,
        color: Color(0xFFF9A825),
        label: 'ぜんバッジかいきん',
        desc: 'すべてのバッジにちょうせんできる',
      ),
    ];

    return Column(
      children: features.map((f) => _buildFeatureRow(f)).toList(),
    );
  }

  Widget _buildFeatureRow(_FeatureItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.color, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  item.desc,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Color(0xFF388E3C), size: 22),
        ],
      ),
    );
  }

  Widget _buildPriceSection(
    BuildContext context,
    SubscriptionService service,
  ) {
    final yearly = service.yearlyProduct;
    final monthly = service.monthlyProduct;

    if (yearly == null && monthly == null) {
      return const Center(
        child: Text(
          'プランをよみこんでいます…',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (yearly != null)
          _PriceCard(
            product: yearly,
            isRecommended: true,
            badge: 'おとく！',
            onTap: () => _onPurchaseTap(context, service, yearly),
          ),
        if (yearly != null && monthly != null) const SizedBox(height: 12),
        if (monthly != null)
          _PriceCard(
            product: monthly,
            isRecommended: false,
            onTap: () => _onPurchaseTap(context, service, monthly),
          ),
      ],
    );
  }

  Widget _buildStoreUnavailableMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange),
      ),
      child: const Column(
        children: [
          Icon(Icons.wifi_off, color: Colors.orange, size: 40),
          SizedBox(height: 8),
          Text(
            'ストアに接続できません\nインターネット接続を確認してください',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => _launchUrl(_kPrivacyPolicyUrl),
          child: const Text(
            'プライバシーポリシー',
            style: TextStyle(fontSize: 12),
          ),
        ),
        const Text('・', style: TextStyle(color: Colors.grey)),
        TextButton(
          onPressed: () => _launchUrl(_kTermsOfServiceUrl),
          child: const Text('りようきやく', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }

  Future<void> _onPurchaseTap(
    BuildContext context,
    SubscriptionService service,
    ProductDetails product,
  ) async {
    await service.purchaseSubscription(product);
    if (!context.mounted) return;
    if (service.isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('プレミアムプランにご加入いただきありがとうございます！'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (service.purchaseError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(service.purchaseError!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _onRestoreTap(
    BuildContext context,
    SubscriptionService service,
  ) async {
    await service.restorePurchases();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          service.isPremium
              ? 'プレミアムプランを復元しました！'
              : 'こうにゅうをかくにんしました',
        ),
        backgroundColor: service.isPremium ? Colors.green : Colors.grey,
      ),
    );
    if (service.isPremium) {
      Navigator.pop(context);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// すでにプレミアム済みの場合に表示するボディ
class _AlreadyPremiumBody extends StatelessWidget {
  final VoidCallback onClose;
  const _AlreadyPremiumBody({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onClose,
        ),
        title: const Text('プレミアム'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.stars, color: Colors.amber, size: 80),
            const SizedBox(height: 24),
            const Text(
              'プレミアムプランに\nご加入済みです！',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'すべてのレベルがご利用いただけます',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: onClose,
              child: const Text('もどる', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

/// 価格カードウィジェット
class _PriceCard extends StatelessWidget {
  final ProductDetails product;
  final bool isRecommended;
  final String? badge;
  final VoidCallback onTap;

  const _PriceCard({
    required this.product,
    required this.isRecommended,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isRecommended ? const Color(0xFF1565C0) : Colors.white,
              foregroundColor:
                  isRecommended ? Colors.white : const Color(0xFF1565C0),
              side: isRecommended
                  ? null
                  : const BorderSide(color: Color(0xFF1565C0), width: 2),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: isRecommended ? 6 : 2,
            ),
            child: Column(
              children: [
                Text(
                  product.title.replaceAll(RegExp(r'\s*\(.*\)$'), ''),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isRecommended ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.price,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (badge != null)
          Positioned(
            top: -12,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final Color color;
  final String label;
  final String desc;

  const _FeatureItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.desc,
  });
}

// デバッグ専用：プレミアム状態を手動切り替えするウィジェット
class DebugPremiumToggle extends StatelessWidget {
  const DebugPremiumToggle({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    final service = context.watch<SubscriptionService>();
    return ListTile(
      leading: const Icon(Icons.bug_report, color: Colors.red),
      title: const Text('[DEBUG] プレミアム切り替え'),
      trailing: Switch(
        value: service.isPremium,
        onChanged: (v) => service.debugSetPremium(v),
      ),
    );
  }
}
