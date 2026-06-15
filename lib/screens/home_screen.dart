import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clock_learning/screens/level_select_screen.dart';
import 'package:clock_learning/screens/progress_screen.dart';
import 'package:clock_learning/screens/free_play_screen.dart';
import 'package:clock_learning/screens/settings_screen.dart';
import 'package:clock_learning/screens/paywall_screen.dart';
import 'package:clock_learning/screens/sticker_book_screen.dart';
import 'package:clock_learning/services/subscription_service.dart';
import 'package:clock_learning/services/sticker_service.dart';
import 'package:clock_learning/services/daily_challenge_service.dart';
import 'package:clock_learning/widgets/clock_mascot_widget.dart';
import 'package:clock_learning/models/level.dart';
import 'package:clock_learning/screens/game_screen.dart';

// ランダムな応援メッセージ
const _messages = [
  'きょうもいっしょにまなぼう！',
  'とけいのプロをめざせ！',
  'なんじかな？いっしょにみよう！',
  'がんばれ！おうえんしてるよ！',
  'シールをいっぱいあつめよう！',
  'まいにちちょっとずつ！えらいね！',
  'きみならできる！ファイト！',
];

/// アプリのホーム画面
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final String _todayMessage;

  @override
  void initState() {
    super.initState();
    // 今日のメッセージを1日1回固定（日付を seed にする）
    final today = DateTime.now();
    final seed = today.year * 10000 + today.month * 100 + today.day;
    _todayMessage = _messages[seed % _messages.length];
  }

  @override
  Widget build(BuildContext context) {
    final subscription = context.watch<SubscriptionService>();
    final stickers = context.watch<StickerService>();
    final challenge = context.watch<DailyChallengeService>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (subscription.isPremium)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Tooltip(
                message: 'プレミアムプラン',
                child: IconButton(
                  icon: const Icon(Icons.stars, color: Colors.amber, size: 30),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PaywallScreen()),
                  ),
                ),
              ),
            ),
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
            colors: [
              Color(0xFF1565C0),
              Color(0xFF42A5F5),
              Color(0xFFE3F2FD),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── マスコット＋吹き出し ─────────────
              _MascotSection(message: _todayMessage),
              // ── ホワイトカードエリア ──────────────
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Column(
                      children: [
                        // ── デイリーチャレンジ + シール ──
                        Row(
                          children: [
                            Expanded(
                              child: _DailyChallengeCard(
                                completed: challenge.completedToday,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StickerCountCard(
                                count: stickers.total,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // ── メインメニュー ──────────────
                        _MenuButton(
                          icon: Icons.search,
                          label: 'とけいをよむ',
                          sublabel: 'とけいをみてじかんをこたえる',
                          color: const Color(0xFF1565C0),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LevelSelectScreen(
                                mode: LevelSelectMode.reading,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _MenuButton(
                          icon: Icons.touch_app,
                          label: 'とけいをあわせる',
                          sublabel: 'はりをうごかしてじかんをあわせる',
                          color: const Color(0xFF0277BD),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LevelSelectScreen(
                                mode: LevelSelectMode.game,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _MenuButton(
                          icon: Icons.play_circle_outline,
                          label: 'じゆうにさわる',
                          sublabel: 'じゆうにとけいをうごかしてみよう',
                          color: const Color(0xFF00695C),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FreePlayScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _MenuButton(
                          icon: Icons.bar_chart,
                          label: 'すすみぐあいをみる',
                          sublabel: 'がくしゅうのきろくをかくにん',
                          color: const Color(0xFF283593),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProgressScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
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

// ── マスコット＋吹き出し ────────────────────────────────

class _MascotSection extends StatelessWidget {
  final String message;
  const _MascotSection({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          const ClockMascotWidget(size: 110),
          // 吹き出し（右上）
          Positioned(
            right: 20,
            top: 0,
            child: _SpeechBubble(text: message),
          ),
        ],
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  final String text;
  const _SpeechBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 160),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
          // しっぽ
          Positioned(
            bottom: 8,
            left: -8,
            child: CustomPaint(
              size: const Size(12, 10),
              painter: _BubbleTailPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BubbleTailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, size.height / 2)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── デイリーチャレンジカード ─────────────────────────────

class _DailyChallengeCard extends StatelessWidget {
  final bool completed;
  const _DailyChallengeCard({required this.completed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: completed
          ? null
          : () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GameScreen(
                    level: Level.easy,
                    isDailyChallenge: true,
                  ),
                ),
              ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 90,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: completed
                ? [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)]
                : [const Color(0xFFFFECB3), const Color(0xFFFFCC02)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: (completed ? Colors.green : Colors.amber)
                  .withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              completed ? '✅' : '⭐',
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(height: 4),
            Text(
              completed ? 'きょうはクリア！' : 'きょうのちょうせん',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: completed
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFF5D4037),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── シール枚数カード ─────────────────────────────────────

class _StickerCountCard extends StatelessWidget {
  final int count;
  const _StickerCountCard({required this.count});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const StickerBookScreen()),
      ),
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE1F5FE), Color(0xFFB3E5FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎯', style: TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              '$count まいのシール',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF01579B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── メニューボタン ───────────────────────────────────────

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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
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
              const Icon(Icons.chevron_right, color: Colors.white70, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
