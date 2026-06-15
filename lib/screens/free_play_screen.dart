import 'dart:async';
import 'package:flutter/material.dart';
import 'package:clock_learning/widgets/clock_widget.dart';
import 'package:clock_learning/widgets/clock_controller.dart';
import 'package:clock_learning/models/level.dart';
import 'package:clock_learning/services/audio_service.dart';

/// 時刻ごとに登場する動物の定義
const _hourAnimals = {
  1: ('🐱', 'ねこ', 'にゃー！'),
  2: ('🐶', 'いぬ', 'わんわん！'),
  3: ('🐰', 'うさぎ', 'ぴょん！'),
  4: ('🐻', 'くま', 'ぐるる！'),
  5: ('🐸', 'かえる', 'けろけろ！'),
  6: ('🐮', 'うし', 'もーもー！'),
  7: ('🐷', 'ぶた', 'ぶーぶー！'),
  8: ('🦊', 'きつね', 'こんこん！'),
  9: ('🐼', 'パンダ', 'もぐもぐ！'),
  10: ('🦁', 'らいおん', 'がおー！'),
  11: ('🐯', 'とら', 'がおがお！'),
  12: ('🦄', 'ユニコーン', 'きらきら～！'),
};

/// じゆうにさわる画面
class FreePlayScreen extends StatefulWidget {
  const FreePlayScreen({super.key});

  @override
  State<FreePlayScreen> createState() => _FreePlayScreenState();
}

class _FreePlayScreenState extends State<FreePlayScreen>
    with TickerProviderStateMixin {
  final ClockController _controller = ClockController();
  AudioService? _audioService;

  int _lastPopupHour = -1;
  bool _showingPopup = false;

  late AnimationController _popupAnim;
  late Animation<double> _scaleAnim;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller.initialize(12, 0, Level.hard);
    _controller.addListener(_onTimeChanged);

    _popupAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnim = CurvedAnimation(parent: _popupAnim, curve: Curves.elasticOut);

    _initAudio();
  }

  Future<void> _initAudio() async {
    final svc = await AudioService.create();
    if (mounted) _audioService = svc;
  }

  @override
  void dispose() {
    _controller.removeListener(_onTimeChanged);
    _controller.dispose();
    _popupAnim.dispose();
    _dismissTimer?.cancel();
    _audioService?.dispose();
    super.dispose();
  }

  void _onTimeChanged() {
    final hour = _controller.getCurrentHour();
    final minute = _controller.getCurrentMinute();

    if (minute == 0 && hour != _lastPopupHour) {
      _lastPopupHour = hour;
      _triggerAnimalPopup(hour);
    }
  }

  void _triggerAnimalPopup(int hour) {
    if (_showingPopup) {
      _dismissTimer?.cancel();
      _popupAnim.forward(from: 0.0);
    } else {
      setState(() => _showingPopup = true);
      _popupAnim.forward(from: 0.0);
    }
    _audioService?.playCorrectSound();

    _dismissTimer?.cancel();
    _dismissTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _popupAnim.reverse().then((_) {
          if (mounted) setState(() => _showingPopup = false);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('じゆうにさわる'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'じっくりさわってみよう！',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              Center(
                child: ClockWidget(
                  controller: _controller,
                  level: Level.hard,
                  size: 300,
                ),
              ),
              const SizedBox(height: 40),
              ListenableBuilder(
                listenable: _controller,
                builder: (context, _) {
                  final hour = _controller.getCurrentHour();
                  final minute = _controller.getCurrentMinute();
                  final timeText =
                      '$hour時${minute == 0 ? 'ちょうど' : '$minute分'}';
                  return Text(
                    timeText,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'はりをうごかしてみてね',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              const Text(
                'ちょうどのじかんにどうぶつがでてくるよ！',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          if (_showingPopup && _hourAnimals.containsKey(_lastPopupHour))
            _AnimalPopup(
              emoji: _hourAnimals[_lastPopupHour]!.$1,
              name: _hourAnimals[_lastPopupHour]!.$2,
              cry: _hourAnimals[_lastPopupHour]!.$3,
              scaleAnim: _scaleAnim,
            ),
        ],
      ),
    );
  }
}

class _AnimalPopup extends StatelessWidget {
  final String emoji;
  final String name;
  final String cry;
  final Animation<double> scaleAnim;

  const _AnimalPopup({
    required this.emoji,
    required this.name,
    required this.cry,
    required this.scaleAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: scaleAnim,
        child: Container(
          width: 220,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                cry,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
