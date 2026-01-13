import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clock_learning/models/level.dart';
import 'package:clock_learning/models/problem.dart';
import 'package:clock_learning/widgets/clock_widget.dart';
import 'package:clock_learning/widgets/clock_controller.dart';
import 'package:clock_learning/services/problem_generator_service.dart';
import 'package:clock_learning/services/progress_service.dart';
import 'package:clock_learning/services/audio_service.dart';
import 'package:clock_learning/services/storage_service.dart';

/// ゲーム画面の状態管理
class GameState extends ChangeNotifier {
  final Level level;
  final ClockController clockController;
  final ProblemGeneratorService problemGenerator;
  final ProgressService progressService;
  final AudioService audioService;

  Problem? _currentProblem;
  List<Problem> _recentProblems = [];
  bool _isChecking = false;
  bool? _lastResult;

  GameState({
    required this.level,
    required this.clockController,
    required this.problemGenerator,
    required this.progressService,
    required this.audioService,
  });

  Problem? get currentProblem => _currentProblem;
  bool get isChecking => _isChecking;
  bool? get lastResult => _lastResult;

  /// ゲームを開始
  void startGame() {
    _generateNextProblem();
  }

  /// 次の問題を生成
  void _generateNextProblem() {
    _currentProblem = problemGenerator.generateProblem(
      level,
      recentProblems: _recentProblems,
    );
    _recentProblems.insert(0, _currentProblem!);
    if (_recentProblems.length > 10) {
      _recentProblems = _recentProblems.take(10).toList();
    }

    // 時計を初期化
    final targetTime = _currentProblem!.targetTime;
    clockController.initialize(
      targetTime.hour,
      targetTime.minute,
      level,
    );

    _isChecking = false;
    _lastResult = null;
    notifyListeners();
  }

  /// 回答を確定
  Future<void> checkAnswer() async {
    if (_currentProblem == null || _isChecking) {
      return;
    }

    _isChecking = true;
    notifyListeners();

    final userHour = clockController.getCurrentHour();
    final userMinute = clockController.getCurrentMinute();
    final isCorrect = problemGenerator.validateAnswer(
      _currentProblem!,
      userHour,
      userMinute,
    );

    _lastResult = isCorrect;

    // 音声フィードバック
    if (isCorrect) {
      await audioService.playCorrectSound();
    } else {
      await audioService.playIncorrectSound();
    }

    // 進捗を記録
    await progressService.recordAnswer(level, isCorrect);
    await progressService.updateLearningDate();

    _isChecking = false;
    notifyListeners();

    // 1.5秒後に次の問題へ
    await Future.delayed(const Duration(milliseconds: 1500));
    _generateNextProblem();
  }
}

/// ゲーム画面
class GameScreen extends StatefulWidget {
  final Level level;

  const GameScreen({
    super.key,
    required this.level,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState _gameState;

  @override
  void initState() {
    super.initState();
    _initializeGameState();
  }

  Future<void> _initializeGameState() async {
    final clockController = ClockController();
    final problemGenerator = ProblemGeneratorService();
    final storageService = await StorageService.create();
    final progressService = ProgressService(storageService);
    final audioService = await AudioService.create();

    _gameState = GameState(
      level: widget.level,
      clockController: clockController,
      problemGenerator: problemGenerator,
      progressService: progressService,
      audioService: audioService,
    );

    _gameState.startGame();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_gameState.currentProblem == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _gameState,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.level.displayName),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Consumer<GameState>(
          builder: (context, gameState, _) {
            return Column(
              children: [
                const SizedBox(height: 20),
                // 問題文
                Text(
                  gameState.currentProblem!.questionText,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                // 時計ウィジェット
                Center(
                  child: ClockWidget(
                    controller: gameState.clockController,
                    size: 300,
                  ),
                ),
                const Spacer(),
                // 正解/不正解の表示
                if (gameState.lastResult != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildResultMessage(gameState.lastResult!),
                  ),
                // 回答確定ボタン
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 200,
                    height: 80,
                    child: ElevatedButton(
                      onPressed: gameState.isChecking
                          ? null
                          : () => gameState.checkAnswer(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, size: 32),
                          SizedBox(width: 8),
                          Text(
                            'こたえをきめる',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
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

  Widget _buildResultMessage(bool isCorrect) {
    if (isCorrect) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'せいかい！',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      );
    } else {
      final problem = _gameState.currentProblem!;
      final targetTime = problem.targetTime;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            const Text(
              'ちがいます',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'せいかいは${targetTime.displayString}です',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.red,
              ),
            ),
          ],
        ),
      );
    }
  }
}
