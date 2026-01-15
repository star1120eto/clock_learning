import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:clock_learning/screens/home_screen.dart';
import 'package:clock_learning/utils/performance_monitor.dart';
import 'package:flutter/foundation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // 縦向き（Portrait）固定
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // パフォーマンス監視を開始（デバッグモードのみ）
  if (kDebugMode) {
    final monitor = PerformanceMonitor();
    monitor.startMonitoring();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '時計学習アプリ',
      theme: ThemeData(
        // 未就学児向けのカラフルなデザイン
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        // 大きなフォントサイズで読みやすく（sp単位で端末のフォントサイズ設定に従う）
        textTheme: TextTheme(
          headlineLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          headlineMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          bodyLarge: const TextStyle(fontSize: 20),
          bodyMedium: const TextStyle(fontSize: 18),
        ),
        // アニメーションの減速モーション対応
        // MediaQuery.of(context).disableAnimations で無効化可能
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
