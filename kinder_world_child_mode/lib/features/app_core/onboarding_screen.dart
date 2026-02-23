import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kinder_world/core/constants/app_constants.dart';
import 'package:kinder_world/core/localization/app_localizations.dart';
import 'package:kinder_world/core/theme/app_colors.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> 
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _pageCount = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pageCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to welcome screen
      context.go('/welcome');
    }
  }

  void _skip() {
    context.go('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final pages = [
      OnboardingPage(
        title: l10n.learn,
        subtitle: l10n.onboardingLearnSubtitle,
        description: l10n.onboardingLearnDescription,
        icon: Icons.school,
        color: AppColors.educational,
        animation: 'learn.json',
      ),
      OnboardingPage(
        title: l10n.play,
        subtitle: l10n.onboardingPlaySubtitle,
        description: l10n.onboardingPlayDescription,
        icon: Icons.games,
        color: AppColors.entertaining,
        animation: 'play.json',
      ),
      OnboardingPage(
        title: l10n.onboardingGrow,
        subtitle: l10n.onboardingGrowSubtitle,
        description: l10n.onboardingGrowDescription,
        icon: Icons.psychology,
        color: AppColors.behavioral,
        animation: 'grow.json',
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    l10n.skip,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: AppConstants.fontSize,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(pages[index]);
                },
              ),
            ),
            
            // Page indicator
            SmoothPageIndicator(
              controller: _pageController,
              count: pages.length,
              effect: ExpandingDotsEffect(
                activeDotColor: pages[_currentPage].color,
                dotColor: colors.surfaceContainerHighest,
                dotHeight: 8,
                dotWidth: 8,
                spacing: 8,
                expansionFactor: 3,
              ),
            ),
            const SizedBox(height: 40),
            
            // Next button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: pages[_currentPage].color,
                  foregroundColor: colors.onPrimary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _currentPage == pages.length - 1 ? l10n.getStarted : l10n.next,
                  style: const TextStyle(
                    fontSize: AppConstants.fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon/Animation
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: page.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Icon(
                    page.icon,
                    size: 80,
                    color: page.color,
                  ),
                ),
                const SizedBox(height: 48),
                
                // Title
                Text(
                  page.title,
                  style: TextStyle(
                    fontSize: AppConstants.largeFontSize * 1.5,
                    fontWeight: FontWeight.bold,
                    color: page.color,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Subtitle
                Text(
                  page.subtitle,
                  style: textTheme.titleSmall?.copyWith(
                    fontSize: AppConstants.fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Description
                Text(
                  page.description,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: AppConstants.fontSize,
                    color: colors.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final String animation;

  const OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.animation,
  });
}
