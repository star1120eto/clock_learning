import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clock_learning/constants/legal_urls.dart';
import 'package:clock_learning/services/subscription_service.dart';
import 'package:clock_learning/services/audio_service.dart';
import 'package:clock_learning/screens/paywall_screen.dart';
import 'package:clock_learning/widgets/parental_gate.dart';

/// 設定画面
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AudioService? _audioService;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _loadAudioSettings();
  }

  Future<void> _loadAudioSettings() async {
    final service = await AudioService.create();
    if (!mounted) return;
    setState(() {
      _audioService = service;
      _isMuted = service.getSettings().isMuted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final subscription = context.watch<SubscriptionService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('せってい'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          // ── おと ──────────────────────────────
          _SectionHeader(label: 'おと'),
          SwitchListTile(
            secondary: Icon(
              _isMuted ? Icons.volume_off : Icons.volume_up,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('おとをならす', style: TextStyle(fontSize: 18)),
            value: !_isMuted,
            onChanged: _audioService == null
                ? null
                : (value) async {
                    await _audioService!.setMuted(!value);
                    setState(() => _isMuted = !value);
                  },
          ),
          const Divider(height: 1),

          // ── プレミアム ────────────────────────
          _SectionHeader(label: 'プレミアム'),
          if (subscription.isPremium) ...[
            ListTile(
              leading: const Icon(Icons.stars, color: Colors.amber, size: 28),
              title: const Text(
                'プレミアムプランご利用中',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('すべてのレベルがご利用いただけます'),
            ),
          ] else ...[
            ListTile(
              leading: const Icon(
                Icons.lock_open,
                color: Color(0xFF1565C0),
                size: 28,
              ),
              title: const Text(
                'プレミアムにアップグレード',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('ふつう・むずかしいレベルをかいきん'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'みる',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () => ParentalGate.guard(
                context,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PaywallScreen()),
                ),
              ),
            ),
          ],
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('こうにゅうをふくげんする', style: TextStyle(fontSize: 16)),
            onTap: () => _onRestoreTap(context, subscription),
          ),
          const Divider(height: 1),

          // ── ほうてき情報 ──────────────────────
          _SectionHeader(label: 'ほうてきじょうほう'),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('プライバシーポリシー', style: TextStyle(fontSize: 16)),
            trailing: const Icon(Icons.open_in_new, size: 16),
            onTap: () => _openExternalLink(context, kPrivacyPolicyUrl),
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('りようきやく', style: TextStyle(fontSize: 16)),
            trailing: const Icon(Icons.open_in_new, size: 16),
            onTap: () => _openExternalLink(context, kTermsOfServiceUrl),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('サポート', style: TextStyle(fontSize: 16)),
            trailing: const Icon(Icons.open_in_new, size: 16),
            onTap: () => _openExternalLink(context, kSupportUrl),
          ),
          const Divider(height: 1),

          // ── アプリ情報 ─────────────────────────
          _SectionHeader(label: 'アプリじょうほう'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('バージョン', style: TextStyle(fontSize: 16)),
            trailing: Text(
              '1.1.0',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ),
          const Divider(height: 1),

          // ── デバッグ（DEBUG ビルドのみ） ─────
          if (kDebugMode) ...[
            _SectionHeader(label: '[DEBUG]'),
            DebugPremiumToggle(),
            const Divider(height: 1),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
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
              : 'こうにゅうをかくにんしました（プレミアムプランなし）',
        ),
        backgroundColor: service.isPremium ? Colors.green : Colors.grey,
      ),
    );
  }

  /// 外部サイトを開く（Apple のキッズ向け要件に合わせ、保護者確認を挟む）
  Future<void> _openExternalLink(BuildContext context, String url) async {
    final passed = await ParentalGate.show(context);
    if (!passed) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
