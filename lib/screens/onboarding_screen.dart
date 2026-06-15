import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clock_learning/screens/home_screen.dart';

const String kOnboardingCompleteKey = 'onboarding_complete';

/// オンボーディング画面（初回起動時のみ表示）
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPageData(
      color: Color(0xFF1565C0),
      secondaryColor: Color(0xFF42A5F5),
      icon: Icons.schedule,
      title: 'とけいをまなぼう！',
      description: 'たのしいゲームで\nとけいのよみかたを\nおぼえよう！',
    ),
    _OnboardingPageData(
      color: Color(0xFF2E7D32),
      secondaryColor: Color(0xFF66BB6A),
      icon: Icons.touch_app,
      title: 'さわってうごかす',
      description: 'とけいのはりを\nゆびでうごかして\nじかんをあわせよう！',
    ),
    _OnboardingPageData(
      color: Color(0xFFE65100),
      secondaryColor: Color(0xFFFF7043),
      icon: Icons.emoji_events,
      title: 'バッジをあつめよう',
      description: 'もんだいをといて\nたくさんのバッジを\nあつめよう！',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kOnboardingCompleteKey, true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, i) => _buildPage(_pages[i]),
          ),
          // ドットインジケーター
          Positioned(
            bottom: 140,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _currentPage ? 28 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color:
                        i == _currentPage ? Colors.white : Colors.white38,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ),
          // つぎへ / はじめる ボタン
          Positioned(
            bottom: 64,
            left: 32,
            right: 32,
            child: SizedBox(
              height: 64,
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage < _pages.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _complete();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _pages[_currentPage].color,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: Text(
                  _currentPage < _pages.length - 1 ? 'つぎへ' : 'はじめる！',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          // スキップボタン
          if (_currentPage < _pages.length - 1)
            Positioned(
              top: 0,
              right: 16,
              child: SafeArea(
                child: TextButton(
                  onPressed: _complete,
                  child: const Text(
                    'スキップ',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardingPageData page) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [page.color, page.secondaryColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  page.icon,
                  size: 90,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                page.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                page.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  height: 1.7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final Color color;
  final Color secondaryColor;
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingPageData({
    required this.color,
    required this.secondaryColor,
    required this.icon,
    required this.title,
    required this.description,
  });
}
