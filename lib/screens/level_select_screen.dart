import 'package:flutter/material.dart';
import 'package:clock_learning/models/level.dart';
import 'package:clock_learning/screens/game_screen.dart';
import 'package:clock_learning/screens/clock_reading_screen.dart';

/// レベル選択画面
class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('レベルをえらんでね'),
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
              // かんたんレベル
              _buildLevelCard(
                context,
                Level.easy,
                Colors.blue,
                'かんたん',
                '◯じをあわせる',
              ),
              const SizedBox(height: 20),
              // ふつうレベル
              _buildLevelCard(
                context,
                Level.normal,
                Colors.orange,
                'ふつう',
                '◯じ◯ふんをあわせる\n（5ふんごと）',
              ),
              const SizedBox(height: 20),
              // むずかしいレベル
              _buildLevelCard(
                context,
                Level.hard,
                Colors.red,
                'むずかしい',
                '◯じ◯ふんをあわせる\n（1ふんごと）',
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'よみとりモード',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('とけいをみてよもう！', style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 16),
              // かんたんレベル（よみとり）
              _buildReadingLevelCard(
                context,
                Level.easy,
                Colors.blue,
                'かんたん',
                '◯じをよむ',
              ),
              const SizedBox(height: 20),
              // ふつうレベル（よみとり）
              _buildReadingLevelCard(
                context,
                Level.normal,
                Colors.orange,
                'ふつう',
                '◯じ◯ふんをよむ\n（5ふんごと）',
              ),
              const SizedBox(height: 20),
              // むずかしいレベル（よみとり）
              _buildReadingLevelCard(
                context,
                Level.hard,
                Colors.red,
                'むずかしい',
                '◯じ◯ふんをよむ\n（1ふんごと）',
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadingLevelCard(
    BuildContext context,
    Level level,
    Color color,
    String levelName,
    String description,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClockReadingScreen(level: level),
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

  Widget _buildLevelCard(
    BuildContext context,
    Level level,
    Color color,
    String levelName,
    String description,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GameScreen(level: level),
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
