import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clock_learning/screens/level_select_screen.dart';
import 'package:clock_learning/screens/progress_screen.dart';
import 'package:clock_learning/screens/free_play_screen.dart';
import 'package:clock_learning/screens/settings_screen.dart';
import 'package:clock_learning/screens/paywall_screen.dart';
import 'package:clock_learning/services/subscription_service.dart';

/// アプリのホーム画面
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subscription = context.watch<SubscriptionService>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // プレミアムバッジ
          if (subscription.isPremium)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Tooltip(
                message: 'プレミアムプラン',
                child: IconButton(
                  icon: const Icon(
                    Icons.stars,
                    color: Colors.amber,
                    size: 30,
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PaywallScreen()),
                  ),
                ),
              ),
            ),
          // 設定ボタン
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5), Color(0xFFE3F2FD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── ヘッダー ──────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.schedule,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'とけいをまなぼう！',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── メニューボタン ────────────────
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F9FF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                    child: Column(
                      children: [
                        _MenuButton(
                          icon: Icons.search,
                          label: 'とけいをよむ',
                          sublabel: 'とけいをみてじかんをこたえる',
                          color: const Color(0xFF00897B),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LevelSelectScreen(
                                mode: LevelSelectMode.reading,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _MenuButton(
                          icon: Icons.touch_app,
                          label: 'とけいをあわせる',
                          sublabel: 'はりをうごかしてじかんをあわせる',
                          color: const Color(0xFF1E88E5),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LevelSelectScreen(
                                mode: LevelSelectMode.game,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _MenuButton(
                          icon: Icons.play_circle_outline,
                          label: 'じゆうにさわる',
                          sublabel: 'じゆうにとけいをうごかしてみよう',
                          color: const Color(0xFF7B1FA2),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FreePlayScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _MenuButton(
                          icon: Icons.bar_chart,
                          label: 'すすみぐあいをみる',
                          sublabel: 'がくしゅうのきろくをかくにん',
                          color: const Color(0xFF2E7D32),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProgressScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      shadowColor: color.withValues(alpha: 0.35),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      sublabel,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.white70,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
