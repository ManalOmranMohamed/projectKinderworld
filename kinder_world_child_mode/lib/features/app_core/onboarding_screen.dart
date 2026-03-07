import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kinder_world/core/localization/app_localizations.dart';
import 'package:kinder_world/router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages(AppLocalizations.of(context)!).length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(Routes.welcome);
    }
  }

  List<_OnboardingData> _pages(AppLocalizations l10n) => [
        _OnboardingData(
          title: l10n.learn,
          subtitle: l10n.onboardingLearnSubtitle,
          description: l10n.onboardingLearnDescription,
          icon: Icons.school_rounded,
          gradientColors: const [Color(0xFF1565C0), Color(0xFF42A5F5)],
          accentColor: const Color(0xFF42A5F5),
        ),
        _OnboardingData(
          title: l10n.play,
          subtitle: l10n.onboardingPlaySubtitle,
          description: l10n.onboardingPlayDescription,
          icon: Icons.sports_esports_rounded,
          gradientColors: const [Color(0xFF7B1FA2), Color(0xFFCE93D8)],
          accentColor: const Color(0xFFCE93D8),
        ),
        _OnboardingData(
          title: l10n.onboardingGrow,
          subtitle: l10n.onboardingGrowSubtitle,
          description: l10n.onboardingGrowDescription,
          icon: Icons.psychology_rounded,
          gradientColors: const [Color(0xFF2E7D32), Color(0xFF66BB6A)],
          accentColor: const Color(0xFF66BB6A),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = _pages(l10n);
    final page = pages[_currentPage];

    return Scaffold(
      body: Stack(
        children: [
          // Full-screen gradient background (animated color change)
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: page.gradientColors,
              ),
            ),
          ),

          // Decorative circle top-right
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),

          // Decorative circle bottom-left
          Positioned(
            bottom: 180,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          // Skip button top-right
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton(
                  onPressed: () => context.go(Routes.welcome),
                  child: Text(
                    l10n.skip,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Page dots top-center
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: SmoothPageIndicator(
                    controller: _pageController,
                    count: pages.length,
                    effect: WormEffect(
                      activeDotColor: Colors.white,
                      dotColor: Colors.white.withValues(alpha: 0.35),
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 6,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Page content
          PageView.builder(
            controller: _pageController,
            itemCount: pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) =>
                _OnboardingPageView(data: pages[index]),
          ),

          // Bottom CTA panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pages[_currentPage].subtitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pages[_currentPage].description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        onPressed: _nextPage,
                        style: FilledButton.styleFrom(
                          backgroundColor: page.gradientColors.first,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          _currentPage == pages.length - 1
                              ? l10n.getStarted
                              : l10n.next,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────

class _OnboardingData {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final Color accentColor;

  const _OnboardingData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.accentColor,
  });
}

class _OnboardingPageView extends StatelessWidget {
  final _OnboardingData data;

  const _OnboardingPageView({required this.data});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 60, bottom: 240),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Large icon in white circle
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.2),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                data.icon,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              data.title,
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -1.5,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
