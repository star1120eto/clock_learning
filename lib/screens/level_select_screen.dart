import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clock_learning/models/level.dart';
import 'package:clock_learning/screens/game_screen.dart';
import 'package:clock_learning/screens/clock_reading_screen.dart';
import 'package:clock_learning/screens/paywall_screen.dart';
import 'package:clock_learning/services/subscription_service.dart';
import 'package:clock_learning/widgets/parental_gate.dart';

enum LevelSelectMode { game, reading }

/// レベル選択画面
/// かんたん（Easy）は無料・ふつう（Normal）・むずかしい（Hard）はプレミアム限定
class LevelSelectScreen extends StatelessWidget {
  final LevelSelectMode mode;

  const LevelSelectScreen({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    final isReading = mode == LevelSelectMode.reading;
    final title = isReading ? 'とけいをよむ' : 'とけいをあわせる';
    final isPremium = context.watch<SubscriptionService>().isPremium;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'どのレベルにする？',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                // かんたん（無料）
                _LevelCard(
                  level: Level.easy,
                  color: const Color(0xFF1E88E5),
                  levelName: 'かんたん',
                  description:
                      isReading ? '◯じをよむ' : '◯じをあわせる',
                  isLocked: false,
                  onTap: () => _navigate(context, Level.easy, isReading),
                ),
                const SizedBox(height: 20),
                // ふつう（プレミアム）
                _LevelCard(
                  level: Level.normal,
                  color: const Color(0xFFE65100),
                  levelName: 'ふつう',
                  description: isReading
                      ? '◯じ◯ふんをよむ\n（5ふんごと）'
                      : '◯じ◯ふんをあわせる\n（5ふんごと）',
                  isLocked: !isPremium,
                  onTap: isPremium
                      ? () => _navigate(context, Level.normal, isReading)
                      : () => _showPaywall(context),
                ),
                const SizedBox(height: 20),
                // むずかしい（プレミアム）
                _LevelCard(
                  level: Level.hard,
                  color: const Color(0xFFC62828),
                  levelName: 'むずかしい',
                  description: isReading
                      ? '◯じ◯ふんをよむ\n（1ふんごと）'
                      : '◯じ◯ふんをあわせる\n（1ふんごと）',
                  isLocked: !isPremium,
                  onTap: isPremium
                      ? () => _navigate(context, Level.hard, isReading)
                      : () => _showPaywall(context),
                ),
                const SizedBox(height: 40),
                // プレミアム案内（未加入の場合）
                if (!isPremium) _PremiumBanner(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, Level level, bool isReading) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            isReading ? ClockReadingScreen(level: level) : GameScreen(level: level),
      ),
    );
  }

  /// 課金画面は保護者確認（ペアレンタルゲート）を通過した場合のみ開く
  void _showPaywall(BuildContext context) {
    ParentalGate.guard(
      context,
      () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PaywallScreen()),
      ),
    );
  }
}

/// レベルカードウィジェット
class _LevelCard extends StatelessWidget {
  final Level level;
  final Color color;
  final String levelName;
  final String description;
  final bool isLocked;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.color,
    required this.levelName,
    required this.description,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isLocked ? 0.75 : 1.0,
        child: Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: isLocked ? Colors.grey[400] : color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (isLocked ? Colors.grey : color).withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // メインコンテンツ
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            levelName,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 鍵アイコン or 矢印
                    if (isLocked)
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock, color: Colors.white, size: 32),
                          SizedBox(height: 4),
                          Text(
                            'プレミアム',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    else
                      const Icon(
                        Icons.play_circle_filled,
                        color: Colors.white70,
                        size: 40,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// プレミアム案内バナー
class _PremiumBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ParentalGate.guard(
        context,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PaywallScreen()),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.stars, color: Colors.amber, size: 32),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'プレミアムプランでもっとたのしもう！',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'ふつう・むずかしいレベルがかいきんされます',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
