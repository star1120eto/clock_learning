import 'package:flutter/material.dart';
import 'package:clock_learning/models/level.dart';
import 'package:clock_learning/screens/game_screen.dart';

/// 結果画面（5問終了後）
/// [retryBuilder] を指定するとリトライ時にその画面に遷移する（省略時は GameScreen）
class ResultScreen extends StatefulWidget {
  final int correctCount;
  final int incorrectCount;
  final Level level;
  final WidgetBuilder? retryBuilder;

  const ResultScreen({
    super.key,
    required this.correctCount,
    required this.incorrectCount,
    required this.level,
    this.retryBuilder,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _starController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _slideAnim;

  bool get _allCorrect => widget.incorrectCount == 0;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnim = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeIn,
    );
    _slideAnim = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );

    _entryController.forward();

    if (_allCorrect) {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _starController.forward();
      });
    } else {
      _starController.value = 1.0; // アニメーションなし
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _allCorrect
                ? [const Color(0xFFFFF8E1), const Color(0xFFFFF3E0)]
                : [const Color(0xFFF5F9FF), const Color(0xFFE3F2FD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 戻るボタン（右上）
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
                  animation: _entryController,
                  builder: (_, child) => Opacity(
                    opacity: _fadeAnim.value,
                    child: Transform.translate(
                      offset: Offset(0, _slideAnim.value),
                      child: child,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildResultTitle(),
                      const SizedBox(height: 28),
                      _buildStarRow(),
                      const SizedBox(height: 28),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: _buildScoreCard(),
                      ),
                      const SizedBox(height: 36),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: _buildButtons(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
          const SizedBox(height: 10),
          const Text(
            'ぜんもんせいかい！',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE65100),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'かんぺきだよ！すごい！',
            style: TextStyle(fontSize: 17, color: Colors.deepOrange),
          ),
        ],
      );
    }
    return Column(
      children: [
        const Text('⏰', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 10),
        const Text(
          'おわったよ！',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1565C0),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.correctCount > 0
              ? 'よくできたね！またちょうせんしてね！'
              : 'またちょうせんしてね！',
          style: const TextStyle(fontSize: 15, color: Colors.blueGrey),
        ),
      ],
    );
  }

  Widget _buildStarRow() {
    const totalStars = 5;
    final filled = widget.correctCount;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalStars, (i) {
        final isFilled = i < filled;
        return AnimatedBuilder(
          animation: _starController,
          builder: (_, __) {
            // 各スターに遅延を持たせてウェーブエフェクト
            final delay = i * 0.12;
            final rawT = _starController.value;
            final t = rawT < delay
                ? 0.0
                : ((rawT - delay) / (1.0 - delay)).clamp(0.0, 1.0);
            final scale = isFilled
                ? 0.4 + Curves.elasticOut.transform(t) * 0.6
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
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
          Container(width: 1, height: 60, color: Colors.grey[200]),
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
          height: 64,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: widget.retryBuilder ?? (_) => GameScreen(level: widget.level),
                ),
              );
            },
            icon: const Icon(Icons.refresh_rounded, size: 24),
            label: const Text(
              'もういちどちょうせん',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.home_outlined, size: 22),
            label: const Text('ホームにもどる', style: TextStyle(fontSize: 17)),
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
        Icon(icon, color: color, size: 36),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
