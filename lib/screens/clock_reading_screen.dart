import 'dart:math';
import 'package:flutter/material.dart';
import 'package:clock_learning/models/level.dart';
import 'package:clock_learning/widgets/clock_widget.dart';
import 'package:clock_learning/widgets/clock_controller.dart';
import 'package:clock_learning/services/audio_service.dart';
import 'package:clock_learning/services/progress_service.dart';
import 'package:clock_learning/services/storage_service.dart';

/// よみとりモード画面
class ClockReadingScreen extends StatefulWidget {
  final Level level;

  const ClockReadingScreen({super.key, required this.level});

  @override
  State<ClockReadingScreen> createState() => _ClockReadingScreenState();
}

class _ClockReadingScreenState extends State<ClockReadingScreen> {
  static const int maxQuestions = 5;

  late final ClockController _clockController;
  late AudioService _audioService;
  late ProgressService _progressService;
  bool _isInitializing = true;

  int _targetHour = 0;
  int _targetMinute = 0;
  int _questionCount = 0;
  int _correctCount = 0;

  String _hourInput = '';
  String _minuteInput = '';
  bool? _lastResult;
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    _clockController = ClockController();
    _initialize();
  }

  Future<void> _initialize() async {
    final storage = await StorageService.create();
    _progressService = ProgressService(storage);
    _audioService = await AudioService.create();
    if (!mounted) return;
    setState(() {
      _isInitializing = false;
    });
    _nextQuestion();
  }

  void _nextQuestion() {
    final r = Random();
    _targetHour = r.nextInt(12) + 1;
    _targetMinute = switch (widget.level) {
      Level.easy => 0,
      Level.normal => (r.nextInt(12)) * 5,
      Level.hard => r.nextInt(60),
    };
    _clockController.initialize(_targetHour, _targetMinute, widget.level);
    setState(() {
      _hourInput = '';
      _minuteInput = '';
      _lastResult = null;
      _isChecked = false;
    });
  }

  void _onNumberTap(String digit) {
    if (_isChecked) return;
    setState(() {
      // Fill hour first (max 2 digits), then minute
      if (_hourInput.length < 2) {
        final next = _hourInput + digit;
        final val = int.tryParse(next) ?? 0;
        if (val <= 12) {
          _hourInput = next;
        }
      } else if (_minuteInput.length < 2) {
        final next = _minuteInput + digit;
        final val = int.tryParse(next) ?? 0;
        if (val <= 59) {
          _minuteInput = next;
        }
      }
    });
  }

  void _onDelete() {
    if (_isChecked) return;
    setState(() {
      if (_minuteInput.isNotEmpty) {
        _minuteInput = _minuteInput.substring(0, _minuteInput.length - 1);
      } else if (_hourInput.isNotEmpty) {
        _hourInput = _hourInput.substring(0, _hourInput.length - 1);
      }
    });
  }

  Future<void> _checkAnswer() async {
    if (_isChecked) return;
    if (_hourInput.isEmpty) return;
    if (widget.level != Level.easy && _minuteInput.isEmpty) return;
    final hour = int.tryParse(_hourInput) ?? -1;
    final minute = int.tryParse(_minuteInput.isEmpty ? '0' : _minuteInput) ?? -1;
    final isCorrect = hour == _targetHour &&
        (widget.level == Level.easy ? minute == 0 : minute == _targetMinute);

    if (isCorrect) {
      await _audioService.playCorrectSound();
      _correctCount++;
    } else {
      await _audioService.playIncorrectSound();
    }
    await _progressService.recordAnswer(widget.level, isCorrect);
    await _progressService.updateLearningDate();

    setState(() {
      _lastResult = isCorrect;
      _isChecked = true;
      _questionCount++;
    });

    if (isCorrect) {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      _goNext();
    }
  }

  void _goNext() {
    if (_questionCount >= maxQuestions) {
      _showResult();
    } else {
      _nextQuestion();
    }
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('けっか'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('せいかい: $_correctCount もん', style: const TextStyle(fontSize: 22, color: Colors.green)),
            Text('まちがい: ${_questionCount - _correctCount} もん', style: const TextStyle(fontSize: 22, color: Colors.red)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // go back
            },
            child: const Text('もどる'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _questionCount = 0;
                _correctCount = 0;
              });
              _nextQuestion();
            },
            child: const Text('もういちど'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final showMinute = widget.level != Level.easy;

    return Scaffold(
      appBar: AppBar(
        title: Text('よみとり - ${widget.level.displayName}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('$_questionCount / $maxQuestions もん',
                    style: const TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          ),
          const Text('なんじなんぷん？', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          // Clock (read-only)
          Center(
            child: ClockWidget(
              controller: _clockController,
              level: widget.level,
              size: 250,
              displayCorrectTime: true,
              correctHour: _targetHour,
              correctMinute: _targetMinute,
            ),
          ),
          const SizedBox(height: 20),
          // Answer display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _inputBox(_hourInput, 'じ', isWrong: _lastResult == false),
              if (showMinute) ...[
                const SizedBox(width: 8),
                _inputBox(_minuteInput, 'ふん', isWrong: _lastResult == false),
              ],
            ],
          ),
          // Result message
          if (_lastResult != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                _lastResult! ? 'せいかい！' : 'まちがい… こたえは $_targetHour 時${showMinute ? " $_targetMinute 分" : ""}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _lastResult! ? Colors.green : Colors.red,
                ),
              ),
            ),
          const Spacer(),
          // Numpad
          _buildNumpad(),
          const SizedBox(height: 16),
          // Check / Next button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              height: 64,
              child: _isChecked && _lastResult == false
                  ? ElevatedButton(
                      onPressed: _goNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('つぎのもんだい', style: TextStyle(fontSize: 20)),
                    )
                  : ElevatedButton(
                      onPressed: _isChecked ? null : _checkAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('こたえる', style: TextStyle(fontSize: 20)),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputBox(String value, String unit, {bool isWrong = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: isWrong ? Colors.red : Colors.blue,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Text(
            value.isEmpty ? '' : value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 4),
        Text(unit, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildNumpad() {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '⌫', '0', '✓'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: keys.map((k) {
          if (k == '✓') {
            return ElevatedButton(
              onPressed: _isChecked ? null : _checkAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('✓', style: TextStyle(fontSize: 24)),
            );
          } else if (k == '⌫') {
            return ElevatedButton(
              onPressed: _onDelete,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[100],
                foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('⌫', style: TextStyle(fontSize: 24)),
            );
          }
          return ElevatedButton(
            onPressed: () => _onNumberTap(k),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[50],
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(k, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          );
        }).toList(),
      ),
    );
  }
}
