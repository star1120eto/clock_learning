import 'package:flutter/material.dart';
import 'package:clock_learning/models/level.dart';
import 'package:clock_learning/services/progress_service.dart';
import 'package:clock_learning/services/storage_service.dart';

/// 進捗画面
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _progressData;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final storageService = await StorageService.create();
      final loadResult = await storageService.loadProgressData();

      if (loadResult is ProgressLoadCorrupted) {
        // データ破損時の処理
        if (!mounted) return;
        // ignore: use_build_context_synchronously
        _showCorruptedDataDialog(context, storageService);
        return;
      }

      final progressService = ProgressService(storageService);
      final progressData = await progressService.getProgress();

      // LevelProgressをJSON形式に変換
      final levelProgressJson = <String, dynamic>{};
      for (final entry in progressData.levelProgress.entries) {
        levelProgressJson[entry.key.name] = entry.value.toJson();
      }
      
      // AchievementをJSON形式に変換
      final achievementsJson = progressData.achievements
          .map((a) => a.toJson())
          .toList();

      if (mounted) {
        setState(() {
          _progressData = {
            'totalCorrectAnswers': progressData.totalCorrectAnswers,
            'totalQuestions': progressData.totalQuestions,
            'accuracyRate': progressData.accuracyRate,
            'consecutiveDays': progressData.consecutiveDays,
            'levelProgress': levelProgressJson,
            'achievements': achievementsJson,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      // エラー発生時は空の進捗データを表示
      if (mounted) {
        setState(() {
          _progressData = {
            'totalCorrectAnswers': 0,
            'totalQuestions': 0,
            'accuracyRate': 0.0,
            'consecutiveDays': 0,
            'levelProgress': {},
            'achievements': [],
          };
          _isLoading = false;
        });
      }
    }
  }

  void _showCorruptedDataDialog(
    BuildContext context,
    StorageService storageService,
  ) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('データがこわれています'),
        content: const Text(
          'データがこわれています。リセットしますか？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await storageService.clearAllData();
              if (mounted) {
                _loadProgress();
              }
            },
            child: const Text('リセット'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('しんちょく'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 総合統計
            _buildStatCard(
              'せいかいすう',
              '${_progressData!['totalCorrectAnswers']}もん',
              Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              'せいかいりつ',
              '${(_progressData!['accuracyRate'] * 100).toStringAsFixed(1)}%',
              Colors.green,
            ),
            const SizedBox(height: 16),
            _buildStatCard(
              'れんぞくがくしゅう',
              '${_progressData!['consecutiveDays']}にち',
              Colors.orange,
            ),
            const SizedBox(height: 32),
            // レベル別進捗
            const Text(
              'レベルべつしんちょく',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildLevelProgress(Level.easy),
            const SizedBox(height: 16),
            _buildLevelProgress(Level.normal),
            const SizedBox(height: 16),
            _buildLevelProgress(Level.hard),
            const SizedBox(height: 32),
            // 達成バッジ
            const Text(
              'とくいなバッジ',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildAchievements(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgress(Level level) {
    final levelProgressMap = _progressData!['levelProgress'] as Map<String, dynamic>;
    final levelKey = level.name; // 'easy', 'normal', 'hard'
    final progressJson = levelProgressMap[levelKey] as Map<String, dynamic>?;
    
    if (progressJson == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              level.displayName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              '0.0%',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    
    final totalAttempts = progressJson['totalAttempts'] as int? ?? 0;
    final correctAnswers = progressJson['correctAnswers'] as int? ?? 0;
    final accuracyRate = totalAttempts > 0 ? correctAnswers / totalAttempts : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            level.displayName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${(accuracyRate * 100).toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    final achievements = _progressData!['achievements'] as List<dynamic>;
    
    if (achievements.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'まだバッジはありません',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: achievements.map((achievement) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber, width: 2),
          ),
          child: Column(
            children: [
              const Icon(Icons.star, size: 40, color: Colors.amber),
              const SizedBox(height: 8),
              Text(
                achievement['name'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
