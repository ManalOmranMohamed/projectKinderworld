import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kinder_world/core/theme/app_colors.dart';
import 'package:kinder_world/core/constants/app_constants.dart';
import 'package:kinder_world/core/models/child_profile.dart';
import 'package:kinder_world/core/models/progress_record.dart';
import 'package:kinder_world/core/providers/child_session_controller.dart';
import 'package:kinder_world/core/providers/progress_controller.dart';
import 'package:kinder_world/core/providers/theme_provider.dart';
import 'package:kinder_world/core/widgets/child_header.dart';
import 'package:kinder_world/features/child_mode/profile/child_profile_screen.dart';

class ChildHomeScreen extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;
  
  const ChildHomeScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  ConsumerState<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends ConsumerState<ChildHomeScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: child,
        );
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: widget.navigationShell,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.home, 'Home'),
                  _buildNavItem(1, Icons.toys, 'Explore'),
                  _buildNavItem(2, Icons.emoji_emotions, 'Fun'),
                  _buildNavItem(3, Icons.psychology, 'AI Buddy'),
                  _buildNavItem(4, Icons.person, 'Profile'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = widget.navigationShell.currentIndex == index;
    final colors = Theme.of(context).colorScheme;
    final color = isSelected ? colors.primary : colors.onSurfaceVariant;
    
    return GestureDetector(
      onTap: () => _onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? colors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppConstants.iconSize,
              color: color,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Child Home Content (separate widget for the home page)
class ChildHomeContent extends ConsumerStatefulWidget {
  const ChildHomeContent({super.key});

  @override
  ConsumerState<ChildHomeContent> createState() => _ChildHomeContentState();
}

class _ChildHomeContentState extends ConsumerState<ChildHomeContent> {
  int _selectedAxisIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load today's progress when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final childProfile = ref.read(currentChildProvider);
      if (childProfile != null) {
        ref.read(progressControllerProvider.notifier).loadTodayProgress(childProfile.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(childSessionControllerProvider);
    final childProfile = sessionState.childProfile;

    // Show loading state
    if (sessionState.isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    // Show error state
    if (sessionState.error != null || childProfile == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: AppColors.error,
                ),
                const SizedBox(height: 24),
                Text(
                  sessionState.error ?? 'No active child session',
                  style: TextStyle(
                    fontSize: AppConstants.fontSize,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    context.go('/child/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Go to Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          floating: true,
          title: const ChildHeader(
            compact: true,
            padding: EdgeInsets.zero,
          ),
          actions: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    iconSize: 20,
                    icon: Icon(
                      Icons.color_lens_outlined,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ChildThemeScreen(),
                        ),
                      );
                    },
                  ),
                  Consumer(
                    builder: (context, ref, _) {
                      final themeState = ref.watch(themeControllerProvider);
                      final isDark = themeState.mode == ThemeMode.dark;
                      return IconButton(
                        visualDensity: VisualDensity.compact,
                        iconSize: 20,
                        icon: Icon(
                          isDark ? Icons.light_mode : Icons.dark_mode,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        onPressed: () {
                          ref.read(themeControllerProvider.notifier).setMode(
                                isDark ? ThemeMode.light : ThemeMode.dark,
                              );
                        },
                      );
                    },
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    iconSize: 20,
                    icon: Icon(
                      Icons.settings,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ChildSettingsScreen(),
                        ),
                      );
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          MoodTypes.getEmoji(childProfile.currentMood ?? MoodTypes.happy),
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getMoodLabel(childProfile.currentMood ?? MoodTypes.happy),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ],
        ),
        
        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Overview
                _buildProgressOverview(childProfile),
                const SizedBox(height: 24),
                
                // Continue Learning
                _buildContinueLearning(),
                const SizedBox(height: 24),
                
                // Daily Goal
                _buildDailyGoal(childProfile),
                const SizedBox(height: 24),
                
                // My Activities History
                _buildMyActivitiesHistory(),
                const SizedBox(height: 24),
                
                // Activity of the Day
                _buildActivityOfTheDay(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getMoodLabel(String mood) {
    switch (mood) {
      case MoodTypes.happy:
        return 'Happy';
      case MoodTypes.sad:
        return 'Sad';
      case MoodTypes.excited:
        return 'Excited';
      case MoodTypes.tired:
        return 'Tired';
      case MoodTypes.angry:
        return 'Angry';
      case MoodTypes.calm:
        return 'Calm';
      default:
        return 'Good';
    }
  }

  Widget _buildProgressOverview(ChildProfile child) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Progress',
            style: TextStyle(
              fontSize: AppConstants.fontSize,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressItem(
                'Level ${child.level}',
                '${child.xpProgress}/1000 XP',
                AppColors.xpColor,
                Icons.star,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChildLevelsScreen(
                        currentLevel: child.level,
                        coins: child.xpProgress.round(),
                      ),
                    ),
                  );
                },
              ),
              _buildProgressItem(
                '${child.streak}',
                'Day Streak',
                AppColors.streakColor,
                Icons.local_fire_department,
              ),
              _buildProgressItem(
                '${child.activitiesCompleted}',
                'Activities',
                AppColors.success,
                Icons.check_circle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(
    String value,
    String label,
    Color color,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              icon,
              size: 30,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: AppConstants.fontSize,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueLearning() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Continue Learning',
          style: TextStyle(
            fontSize: AppConstants.fontSize,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.educational.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.educational.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.educational.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school,
                  size: 30,
                  color: AppColors.educational,
                ),
              ),
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Learning',
                      style: TextStyle(
                        fontSize: AppConstants.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Explore new topics and activities',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              
              ElevatedButton(
                onPressed: () {
                  context.go('/child/learn');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.educational,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Start'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDailyGoal(ChildProfile child) {
    return FutureBuilder<List<ProgressRecord>>(
      future: ref.read(progressControllerProvider.notifier).loadTodayProgress(child.id),
      builder: (context, snapshot) {
        final todayActivities = snapshot.hasData ? snapshot.data!.length : 0;
        const targetActivities = 3; // Default daily goal
        final progress = targetActivities > 0 ? todayActivities / targetActivities : 0.0;
        final clampedProgress = progress > 1.0 ? 1.0 : progress;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Goal',
              style: TextStyle(
                fontSize: AppConstants.fontSize,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Complete $targetActivities activities',
                        style: TextStyle(
                          fontSize: AppConstants.fontSize,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '$todayActivities/$targetActivities',
                      style: const TextStyle(
                          fontSize: AppConstants.fontSize,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: clampedProgress,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMyActivitiesHistory() {
    final axes = [
      const _AxisHistory(
        index: 0,
        label: 'Behavior',
        color: AppColors.behavioral,
        icon: Icons.favorite,
        items: [
          _HistoryItem(title: 'Sharing Stars', subtitle: 'Today - 8 min', xp: 30),
          _HistoryItem(title: 'Kind Words', subtitle: 'Yesterday - 6 min', xp: 20),
          _HistoryItem(title: 'Helping Hands', subtitle: '2 days ago - 10 min', xp: 40),
        ],
      ),
      const _AxisHistory(
        index: 1,
        label: 'Learning',
        color: AppColors.educational,
        icon: Icons.school,
        items: [
          _HistoryItem(title: 'Numbers Adventure', subtitle: 'Today - 12 min', xp: 45),
          _HistoryItem(title: 'Color Quest', subtitle: 'Yesterday - 7 min', xp: 25),
          _HistoryItem(title: 'Story Time', subtitle: '2 days ago - 9 min', xp: 35),
        ],
      ),
      const _AxisHistory(
        index: 2,
        label: 'Skills',
        color: AppColors.skillful,
        icon: Icons.extension,
        items: [
          _HistoryItem(title: 'Puzzle Builder', subtitle: 'Today - 5 min', xp: 18),
          _HistoryItem(title: 'Shape Match', subtitle: 'Yesterday - 8 min', xp: 28),
          _HistoryItem(title: 'Memory Game', subtitle: '2 days ago - 11 min', xp: 38),
        ],
      ),
      const _AxisHistory(
        index: 3,
        label: 'Fun',
        color: AppColors.entertaining,
        icon: Icons.music_note,
        items: [
          _HistoryItem(title: 'Dance Party', subtitle: 'Today - 6 min', xp: 22),
          _HistoryItem(title: 'Sing Along', subtitle: 'Yesterday - 5 min', xp: 18),
          _HistoryItem(title: 'Magic Show', subtitle: '2 days ago - 9 min', xp: 32),
        ],
      ),
    ];

    final selectedAxis = axes[_selectedAxisIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Activities',
          style: TextStyle(
            fontSize: AppConstants.fontSize,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(axes.length, (index) {
              final axis = axes[index];
              final isSelected = index == _selectedAxisIndex;
              return Padding(
                padding: EdgeInsets.only(right: index == axes.length - 1 ? 0 : 12),
                child: _buildAxisChip(axis, isSelected),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: List.generate(selectedAxis.items.length, (index) {
            final item = selectedAxis.items[index];
            return Padding(
              padding: EdgeInsets.only(bottom: index == selectedAxis.items.length - 1 ? 0 : 12),
              child: _buildHistoryCard(item, selectedAxis),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildAxisChip(_AxisHistory axis, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAxisIndex = axis.index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? axis.color.withValues(alpha: 0.2) : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? axis.color : Theme.of(context).colorScheme.surfaceContainerHighest,
            width: 1.2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: axis.color.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Icon(axis.icon, size: 18, color: isSelected ? axis.color : Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              axis.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? axis.color : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(_HistoryItem item, _AxisHistory axis) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: axis.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(axis.icon, color: axis.color, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: AppConstants.fontSize,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: axis.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+${item.xp} XP',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: axis.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityOfTheDay() {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.star,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Activity of the Day',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppConstants.fontSize,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 360;
              final iconSize = isNarrow ? 64.0 : 80.0;
              final content = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore New Activities',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppConstants.fontSize,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Discover something amazing!',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '+50 XP Bonus',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.xpColor,
                    ),
                  ),
                ],
              );

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.lightbulb,
                            size: 36,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: content),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.go('/child/home/activity-of-day');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.secondary,
                          foregroundColor: colors.onSecondary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Start Activity'),
                      ),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.lightbulb,
                      size: 40,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: content),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.go('/child/home/activity-of-day');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.secondary,
                      foregroundColor: colors.onSecondary,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Start Activity'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AxisHistory {
  final int index;
  final String label;
  final Color color;
  final IconData icon;
  final List<_HistoryItem> items;

  const _AxisHistory({
    required this.index,
    required this.label,
    required this.color,
    required this.icon,
    required this.items,
  });
}

class _HistoryItem {
  final String title;
  final String subtitle;
  final int xp;

  const _HistoryItem({
    required this.title,
    required this.subtitle,
    required this.xp,
  });
}
