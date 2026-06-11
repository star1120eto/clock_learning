import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clock_learning/screens/home_screen.dart';
import 'package:clock_learning/screens/onboarding_screen.dart';
import 'package:clock_learning/services/subscription_service.dart';
import 'package:clock_learning/services/sticker_service.dart';
import 'package:clock_learning/services/daily_challenge_service.dart';
import 'package:clock_learning/utils/performance_monitor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 縦向き（Portrait）固定
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // パフォーマンス監視を開始（デバッグモードのみ）
  if (kDebugMode) {
    final monitor = PerformanceMonitor();
    monitor.startMonitoring();
  }

  // オンボーディング完了フラグを確認
  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete =
      prefs.getBool(kOnboardingCompleteKey) ?? false;

  runApp(MyApp(showOnboarding: !onboardingComplete));
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;

  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SubscriptionService()),
        ChangeNotifierProvider(create: (_) => StickerService()),
        ChangeNotifierProvider(create: (_) => DailyChallengeService()),
      ],
      child: MaterialApp(
        title: 'とけいがくしゅう',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1565C0),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            headlineMedium: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            bodyLarge: TextStyle(fontSize: 20),
            bodyMedium: TextStyle(fontSize: 18),
          ),
        ),
        home: showOnboarding ? const OnboardingScreen() : const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
