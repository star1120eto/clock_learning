import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clock_learning/models/level.dart';
import 'package:clock_learning/models/sticker.dart';
import 'package:clock_learning/screens/game_screen.dart';
import 'package:clock_learning/services/sticker_service.dart';
import 'package:clock_learning/services/daily_challenge_service.dart';

/// 結果画面（5問終了後）
class ResultScreen extends StatefulWidget {
  final int correctCount;
  final int incorrectCount;
  final Level level;
  final bool isDailyChallenge;
  final WidgetBuilder? retryBuilder;

  const ResultScreen({
    super.key,
    required this.correctCount,
    required this.incorrectCount,
    required this.level,
    this.isDailyChallenge = false,
    this.retryBuilder,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final AnimationController _starCtrl;
  late final AnimationController _stickerCtrl;
  late final AnimationController _confettiCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _slideAnim;

  bool get _allCorrect => widget.incorrectCount == 0;

  int get _stickersEarned =>
      widget.correctCount + (_allCorrect ? 3 : 0) + (widget.isDailyChallenge ? 5 : 0);

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _starCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _stickerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeIn);
    _slideAnim = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut),
    );

    _entryCtrl.forward();

    if (_allCorrect) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _starCtrl.forward();
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _confettiCtrl.forward();
      });
    } else {
      _starCtrl.value = 1.0;
    }

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _stickerCtrl.forward();
    });

    // シール付与・デイリーチャレンジ完了を副作用として実行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<StickerService>().addStickers(_stickersEarned);
      if (widget.isDailyChallenge) {
        context.read<DailyChallengeService>().markCompleted();
      }
    });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _starCtrl.dispose();
    _stickerCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── 背景グラデーション ─────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _allCorrect
                    ? [const Color(0xFFFFF8E1), const Color(0xFFFFF3E0)]
                    : [const Color(0xFFF5F9FF), const Color(0xFFE3F2FD)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // ── はなまる紙吹雪（完全正解時） ───
          if (_allCorrect)
            _ConfettiOverlay(controller: _confettiCtrl),
          // ── メインコンテンツ ────────────────
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'もどる',
                        style: TextStyle(color: Colors.black38, fontSize: 15),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _entryCtrl,
                    builder: (_, child) => Opacity(
                      opacity: _fadeAnim.value,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnim.value),
                        child: child,
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          _buildResultTitle(),
                          const SizedBox(height: 20),
                          _buildStarRow(),
                          const SizedBox(height: 20),
                          _buildScoreCard(),
                          const SizedBox(height: 16),
                          // シール獲得バナー
                          _StickerAwardBanner(
                            count: _stickersEarned,
                            isDailyChallenge: widget.isDailyChallenge,
                            controller: _stickerCtrl,
                          ),
                          const SizedBox(height: 24),
                          _buildButtons(context),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultTitle() {
    if (_allCorrect) {
      return Column(
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 700),
            tween: Tween(begin: 0.3, end: 1.0),
            curve: Curves.elasticOut,
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: const Text('🎉', style: TextStyle(fontSize: 72)),
          ),
          const SizedBox(height: 8),
          const Text(
            'ぜんもんせいかい！',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE65100),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'かんぺきだよ！すごい！',
            style: TextStyle(fontSize: 16, color: Colors.deepOrange),
          ),
        ],
      );
    }
    return Column(
      children: [
        const Text('⏰', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 8),
        const Text(
          'おわったよ！',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1565C0),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.correctCount > 0 ? 'よくできたね！またちょうせんしてね！' : 'またちょうせんしてね！',
          style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
        ),
      ],
    );
  }

  Widget _buildStarRow() {
    const total = 5;
    final filled = widget.correctCount;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isFilled = i < filled;
        return AnimatedBuilder(
          animation: _starCtrl,
          builder: (_, __) {
            final delay = (i * 0.12).clamp(0.0, 0.8);
            final rawT = _starCtrl.value;
            final t = rawT < delay
                ? 0.0
                : ((rawT - delay) / (1.0 - delay)).clamp(0.0, 1.0);
            final scale = isFilled
                ? (0.4 + Curves.elasticOut.transform(t) * 0.6).clamp(0.0, 1.4)
                : 1.0;
            return Transform.scale(
              scale: scale,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 46,
                  color: isFilled ? Colors.amber : Colors.grey[300],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildScoreCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ScoreItem(
            icon: Icons.check_circle_rounded,
            color: Colors.green,
            label: 'せいかい',
            value: '${widget.correctCount}もん',
          ),
          Container(width: 1, height: 56, color: Colors.grey[200]),
          _ScoreItem(
            icon: Icons.cancel_rounded,
            color: Colors.redAccent,
            label: 'まちがい',
            value: '${widget.incorrectCount}もん',
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 62,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: widget.retryBuilder ??
                      (_) => GameScreen(level: widget.level),
                ),
              );
            },
            icon: const Icon(Icons.refresh_rounded, size: 22),
            label: const Text(
              'もういちどちょうせん',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.home_outlined, size: 20),
            label: const Text('ホームにもどる', style: TextStyle(fontSize: 16)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── シール獲得バナー ─────────────────────────────────────

class _StickerAwardBanner extends StatelessWidget {
  final int count;
  final bool isDailyChallenge;
  final AnimationController controller;

  const _StickerAwardBanner({
    required this.count,
    required this.isDailyChallenge,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = Curves.elasticOut.transform(controller.value.clamp(0.0, 1.0));
        final scale = (0.4 + t * 0.6).clamp(0.0, 1.2);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFECB3), Color(0xFFFFD54F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // シール絵文字ランダム表示
                _buildStickerEmojis(),
                const SizedBox(height: 8),
                Text(
                  'シールを $count まいゲット！🎉',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                  ),
                ),
                if (isDailyChallenge) ...[
                  const SizedBox(height: 4),
                  const Text(
                    '🌟 きょうのチャレンジクリアで +5まい！',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFFE65100),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStickerEmojis() {
    // 獲得シールをランダムで最大6個表示
    final displayCount = count.clamp(0, 6);
    if (displayCount == 0) return const SizedBox.shrink();
    final rng = Random(count);
    final emojis = List.generate(
      displayCount,
      (i) => kStickerTypes[rng.nextInt(kStickerTypes.length)].emoji,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: emojis
          .map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Text(e, style: const TextStyle(fontSize: 26)),
            ),
          )
          .toList(),
    );
  }
}

// ── 紙吹雪オーバーレイ（完全正解時） ───────────────────────

class _ConfettiOverlay extends StatelessWidget {
  final AnimationController controller;
  const _ConfettiOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return IgnorePointer(
          child: CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _ConfettiPainter(controller.value),
          ),
        );
      },
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  static const int _count = 40;
  static final List<_Confetti> _particles = List.generate(
    _count,
    (i) => _Confetti(Random(i * 31337)),
  );

  _ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final t = ((progress - p.delay) / (1.0 - p.delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final x = p.startX * size.width;
      final y = p.startY * size.height + t * size.height * p.speed;
      final alpha = (1.0 - t * 1.2).clamp(0.0, 1.0);

      if (alpha <= 0) continue;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * p.rotation * pi * 2);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.5,
          ),
          const Radius.circular(2),
        ),
        Paint()..color = p.color.withValues(alpha: alpha),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

class _Confetti {
  final double startX;
  final double startY;
  final double speed;
  final double delay;
  final double size;
  final double rotation;
  final Color color;

  static const _colors = [
    Color(0xFFF44336), Color(0xFFFF9800), Color(0xFFFFEB3B),
    Color(0xFF4CAF50), Color(0xFF2196F3), Color(0xFF9C27B0),
    Color(0xFFFF5722), Color(0xFF00BCD4),
  ];

  _Confetti(Random rng)
      : startX = rng.nextDouble(),
        startY = -0.1 - rng.nextDouble() * 0.3,
        speed = 0.5 + rng.nextDouble() * 0.5,
        delay = rng.nextDouble() * 0.4,
        size = 8 + rng.nextDouble() * 10,
        rotation = (rng.nextDouble() - 0.5) * 4,
        color = _colors[rng.nextInt(_colors.length)];
}

// ── スコア表示アイテム ────────────────────────────────────

class _ScoreItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _ScoreItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 34),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
