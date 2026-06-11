import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clock_learning/models/sticker.dart';
import 'package:clock_learning/services/sticker_service.dart';

/// シール帳画面 — 貯めたシールを一覧表示する
class StickerBookScreen extends StatefulWidget {
  const StickerBookScreen({super.key});

  @override
  State<StickerBookScreen> createState() => _StickerBookScreenState();
}

class _StickerBookScreenState extends State<StickerBookScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _revealCtrl;

  @override
  void initState() {
    super.initState();
    _revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();
  }

  @override
  void dispose() {
    _revealCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = context.watch<StickerService>().total;
    const totalSlots = 30;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        title: const Text('🎯 シールちょう'),
        backgroundColor: const Color(0xFFFFF9C4),
        foregroundColor: Colors.brown[800],
        elevation: 1,
      ),
      body: Column(
        children: [
          // ── ヘッダー ────────────────────────────
          _buildHeader(count),
          // ── シールグリッド ──────────────────────
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: totalSlots,
              itemBuilder: (context, i) {
                final isFilled = i < count;
                return AnimatedBuilder(
                  animation: _revealCtrl,
                  builder: (_, __) {
                    final delay = (i * 0.025).clamp(0.0, 0.7);
                    final t = ((_revealCtrl.value - delay) /
                            (1.0 - delay))
                        .clamp(0.0, 1.0);
                    final scale = isFilled
                        ? Curves.elasticOut.transform(t)
                        : 1.0;
                    return Transform.scale(
                      scale: scale.clamp(0.0, 1.4),
                      child: _StickerCell(index: i, isFilled: isFilled),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFECB3), Color(0xFFFFF9C4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD600), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // シール枚数
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'もっているシール',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.brown,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE65100),
                      height: 1,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6, left: 4),
                    child: Text(
                      'まい',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE65100),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          // はげましメッセージ
          Flexible(
            child: Text(
              stickerEncouragementMessage(count),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.brown,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StickerCell extends StatelessWidget {
  final int index;
  final bool isFilled;

  const _StickerCell({required this.index, required this.isFilled});

  @override
  Widget build(BuildContext context) {
    if (!isFilled) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.amber.withValues(alpha: 0.06),
          border: Border.all(
            color: Colors.amber.withValues(alpha: 0.35),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            '${index + 1}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.amber.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    final def = kStickerTypes[index % kStickerTypes.length];
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: def.bgColor,
        boxShadow: [
          BoxShadow(
            color: def.bgColor.withValues(alpha: 0.55),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          def.emoji,
          style: const TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
