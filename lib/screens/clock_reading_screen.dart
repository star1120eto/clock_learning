import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:clock_learning/models/level.dart';
import 'package:clock_learning/screens/result_screen.dart';
import 'package:clock_learning/widgets/responsive_clock.dart';
import 'package:clock_learning/widgets/clock_controller.dart';
import 'package:clock_learning/services/audio_service.dart';
import 'package:clock_learning/services/progress_service.dart';
import 'package:clock_learning/services/storage_service.dart';

enum _InputField { hour, minute }

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
  int _prevTargetHour = -1;
  int _prevTargetMinute = -1;
  int _questionCount = 0;
  int _correctCount = 0;

  String _hourInput = '';
  String _minuteInput = '';
  bool? _lastResult;
  bool _isChecked = false;
  _InputField _activeField = _InputField.hour;

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
    final r = math.Random();
    int newHour;
    int newMinute;
    int attempts = 0;
    do {
      newHour = r.nextInt(12) + 1;
      newMinute = switch (widget.level) {
        Level.easy => 0,
        Level.normal => (r.nextInt(12)) * 5,
        Level.hard => r.nextInt(60),
      };
      attempts++;
    } while (
      newHour == _prevTargetHour &&
      newMinute == _prevTargetMinute &&
      attempts < 20
    );
    _prevTargetHour = _targetHour;
    _prevTargetMinute = _targetMinute;
    _targetHour = newHour;
    _targetMinute = newMinute;
    _clockController.initialize(_targetHour, _targetMinute, widget.level);
    setState(() {
      _hourInput = '';
      _minuteInput = '';
      _lastResult = null;
      _isChecked = false;
      _activeField = _InputField.hour;
    });
  }

  void _onNumberTap(String digit) {
    if (_isChecked) return;
    setState(() {
      if (_activeField == _InputField.hour) {
        final next = _hourInput + digit;
        final val = int.tryParse(next) ?? 0;
        if (val <= 12 && val > 0) {
          _hourInput = next;
          // 2桁になったら自動でふん側へ移動
          if (_hourInput.length == 2 && widget.level != Level.easy) {
            _activeField = _InputField.minute;
          }
        } else if (_hourInput.length == 1) {
          // 1桁の時に次の数字が12を超えるなら自動でふん側へ移動して入力
          if (widget.level != Level.easy) {
            _activeField = _InputField.minute;
            final mVal = int.tryParse(digit) ?? 0;
            if (mVal <= 59) {
              _minuteInput = digit;
            }
          }
        }
      } else {
        // ふん側への入力
        final next = _minuteInput + digit;
        final val = int.tryParse(next) ?? 0;
        if (val <= 59 && _minuteInput.length < 2) {
          _minuteInput = next;
        }
      }
    });
  }

  void _onDelete() {
    if (_isChecked) return;
    setState(() {
      if (_activeField == _InputField.minute) {
        if (_minuteInput.isNotEmpty) {
          _minuteInput = _minuteInput.substring(0, _minuteInput.length - 1);
        } else {
          // ふん側が空のときはじ側へ戻ってじ側を削除
          _activeField = _InputField.hour;
          if (_hourInput.isNotEmpty) {
            _hourInput = _hourInput.substring(0, _hourInput.length - 1);
          }
        }
      } else {
        if (_hourInput.isNotEmpty) {
          _hourInput = _hourInput.substring(0, _hourInput.length - 1);
        }
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          correctCount: _correctCount,
          incorrectCount: _questionCount - _correctCount,
          level: widget.level,
          // リトライ時もよみとりモードに戻る
          retryBuilder: (_) => ClockReadingScreen(level: widget.level),
        ),
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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 縦幅が狭い端末では余白と文字を詰めて、すべての要素が画面に収まるようにする
            final compact = constraints.maxHeight < 640;
            final gap = compact ? 6.0 : 12.0;

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: compact ? 2 : 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '$_questionCount / $maxQuestions もん',
                        style: TextStyle(
                          fontSize: compact ? 15 : 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'なんじなんぷん？',
                  style: TextStyle(
                    fontSize: compact ? 20 : 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: gap),
                // 時計は残りの縦幅に合わせて伸縮する
                Expanded(
                  flex: 5,
                  child: ResponsiveClock(
                    controller: _clockController,
                    level: widget.level,
                    maxSize: 250,
                    minSize: 110,
                    displayCorrectTime: true,
                    correctHour: _targetHour,
                    correctMinute: _targetMinute,
                  ),
                ),
                SizedBox(height: gap),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _isChecked
                          ? null
                          : () => setState(() => _activeField = _InputField.hour),
                      child: _inputBox(
                        _hourInput,
                        'じ',
                        isWrong: _lastResult == false,
                        isActive: !_isChecked && _activeField == _InputField.hour,
                        compact: compact,
                      ),
                    ),
                    if (showMinute) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _isChecked
                            ? null
                            : () =>
                                setState(() => _activeField = _InputField.minute),
                        child: _inputBox(
                          _minuteInput,
                          'ふん',
                          isWrong: _lastResult == false,
                          isActive:
                              !_isChecked && _activeField == _InputField.minute,
                          compact: compact,
                        ),
                      ),
                    ],
                  ],
                ),
                if (_lastResult != null)
                  Padding(
                    padding: EdgeInsets.all(compact ? 4 : 8),
                    child: Text(
                      _lastResult!
                          ? 'せいかい！'
                          : 'まちがい… こたえは $_targetHour じ${showMinute ? " $_targetMinute ふん" : ""}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: compact ? 17 : 22,
                        fontWeight: FontWeight.bold,
                        color: _lastResult! ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                SizedBox(height: gap),
                // テンキーも残りの縦幅に合わせて伸縮する
                Expanded(
                  flex: 5,
                  child: _buildNumpad(compact),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: compact ? 4 : 8,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: compact ? 52 : 64,
                    child: _isChecked && _lastResult == false
                        ? ElevatedButton(
                            onPressed: _goNext,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'つぎのもんだい',
                              style: TextStyle(fontSize: compact ? 18 : 20),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _isChecked ? null : _checkAnswer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'こたえる',
                              style: TextStyle(fontSize: compact ? 18 : 20),
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _inputBox(
    String value,
    String unit, {
    bool isWrong = false,
    bool isActive = false,
    bool compact = false,
  }) {
    final Color borderColor;
    final double borderWidth;
    if (isWrong) {
      borderColor = Colors.red;
      borderWidth = 2;
    } else if (isActive) {
      borderColor = Colors.orange;
      borderWidth = 3;
    } else {
      borderColor = Colors.blue;
      borderWidth = 2;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 62 : 72,
          height: compact ? 46 : 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: borderWidth),
            borderRadius: BorderRadius.circular(8),
            color: isActive ? Colors.orange.withValues(alpha: 0.08) : Colors.white,
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: compact ? 24 : 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          unit,
          style: TextStyle(
            fontSize: compact ? 19 : 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// テンキー。与えられた領域にちょうど収まるようボタンの縦横比を計算する。
  Widget _buildNumpad(bool compact) {
    final keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '⌫', '0', '✓'];
    const spacing = 8.0;
    const columns = 3;
    const rows = 4;

    return LayoutBuilder(
      builder: (context, constraints) {
        // 横幅の広い端末でテンキーが間延びしないよう上限を設ける
        final width = math.min(constraints.maxWidth - 64, 360.0);
        final cellWidth = (width - spacing * (columns - 1)) / columns;
        final availableHeight = constraints.maxHeight;
        final cellHeight = (availableHeight - spacing * (rows - 1)) / rows;
        // 高さが取れない場合に備えて既定の縦横比にフォールバックする
        final aspectRatio =
            cellHeight > 0 ? math.max(cellWidth / cellHeight, 1.1) : 2.0;
        final fontSize = compact ? 20.0 : 24.0;

        return Center(
          child: SizedBox(
            width: width,
            child: GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: aspectRatio,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              children: keys.map((k) {
                if (k == '✓') {
                  return ElevatedButton(
                    onPressed: _isChecked ? null : _checkAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('✓', style: TextStyle(fontSize: fontSize)),
                  );
                } else if (k == '⌫') {
                  return ElevatedButton(
                    onPressed: _onDelete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[100],
                      foregroundColor: Colors.red,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('⌫', style: TextStyle(fontSize: fontSize)),
                  );
                }
                return ElevatedButton(
                  onPressed: () => _onNumberTap(k),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[50],
                    foregroundColor: Colors.black87,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    k,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
