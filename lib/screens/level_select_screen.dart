import 'package:flutter/material.dart';
import 'package:clock_learning/models/level.dart';
import 'package:clock_learning/screens/game_screen.dart';
import 'package:clock_learning/screens/clock_reading_screen.dart';

enum LevelSelectMode { game, reading }

/// レベル選択画面
class LevelSelectScreen extends StatelessWidget {
  final LevelSelectMode mode;

  const LevelSelectScreen({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    final isReading = mode == LevelSelectMode.reading;
    final title = isReading ? 'とけいをよむ' : 'とけいをあわせる';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Center(
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
              _buildLevelCard(
                context,
                Level.easy,
                Colors.blue,
                'かんたん',
                isReading ? '◯じをよむ' : '◯じをあわせる',
                isReading,
              ),
              const SizedBox(height: 20),
              _buildLevelCard(
                context,
                Level.normal,
                Colors.orange,
                'ふつう',
                isReading ? '◯じ◯ふんをよむ\n（5ふんごと）' : '◯じ◯ふんをあわせる\n（5ふんごと）',
                isReading,
              ),
              const SizedBox(height: 20),
              _buildLevelCard(
                context,
                Level.hard,
                Colors.red,
                'むずかしい',
                isReading ? '◯じ◯ふんをよむ\n（1ふんごと）' : '◯じ◯ふんをあわせる\n（1ふんごと）',
                isReading,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(
    BuildContext context,
    Level level,
    Color color,
    String levelName,
    String description,
    bool isReading,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => isReading
                ? ClockReadingScreen(level: level)
                : GameScreen(level: level),
          ),
        );
      },
      child: Container(
        width: 280,
        height: 120,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              levelName,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
