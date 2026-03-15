import 'package:flutter/material.dart';
import 'package:clock_learning/widgets/clock_widget.dart';
import 'package:clock_learning/widgets/clock_controller.dart';
import 'package:clock_learning/models/level.dart';

/// じゆうにさわる画面
class FreePlayScreen extends StatefulWidget {
  const FreePlayScreen({super.key});

  @override
  State<FreePlayScreen> createState() => _FreePlayScreenState();
}

class _FreePlayScreenState extends State<FreePlayScreen> {
  final ClockController _controller = ClockController();

  @override
  void initState() {
    super.initState();
    _controller.initialize(12, 0, Level.hard);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('じゆうにさわる'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
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
              final timeText = '$hour時${minute == 0 ? 'ちょうど' : '$minute分'}';
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
        ],
      ),
    );
  }
}
