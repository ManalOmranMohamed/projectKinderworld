import 'package:flutter/foundation.dart';
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
import 'package:kinder_world/core/widgets/avatar_view.dart';
import 'package:kinder_world/app.dart';
import 'package:kinder_world/core/localization/app_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:kinder_world/core/subscription/plan_info.dart';
import 'package:kinder_world/core/widgets/plan_guard.dart';
import 'package:kinder_world/core/widgets/plan_status_banner.dart';
import 'package:kinder_world/core/widgets/dashboard_theme_switch.dart';

class ParentDashboardScreen extends ConsumerStatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  ConsumerState<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends ConsumerState<ParentDashboardScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  Future<List<ChildProfile>>? _childrenFuture;
  String? _cachedParentId;
  // Theme mode handled via ThemeController

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

  List<Map<String, dynamic>> _extractChildrenList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    if (data is Map) {
      final listData =
          data['children'] ?? data['data'] ?? data['results'] ?? data['items'];
      if (listData is List) {
        return listData
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }
    return [];
  }

  String? _parseChildId(Map<String, dynamic> data) {
    final id = data['id'] ?? data['child_id'] ?? data['childId'];
    if (id == null) return null;
    return id.toString();
  }

  int _parseInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  DateTime _parseDate(dynamic value, DateTime fallback) {
    if (value == null) return fallback;
    if (value is DateTime) return value;
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      return parsed ?? fallback;
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is double) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return fallback;
  }

  DateTime? _parseNullableDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is double) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return null;
  }

  DateTime? _parseBirthDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is double) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return null;
  }

  int _ageFromBirthDate(DateTime? birthDate) {
    if (birthDate == null) return 0;
    final now = DateTime.now();
    var age = now.year - birthDate.year;
    final hasHadBirthday = (now.month > birthDate.month) ||
        (now.month == birthDate.month && now.day >= birthDate.day);
    if (!hasHadBirthday) age -= 1;
    return age.clamp(0, 120);
  }

  int _resolveAgeFromApi(Map<String, dynamic> data, ChildProfile? existing) {
    final apiAge = _parseInt(data['age'], 0);
    final birthDate = _parseBirthDate(
      data['birthdate'] ??
          data['birth_date'] ??
          data['date_of_birth'] ??
          data['dob'],
    );
    final computedAge = _ageFromBirthDate(birthDate);

    if (kDebugMode) {
      debugPrint(
        'Child age resolve: apiAge=$apiAge, birthDate=$birthDate, computedAge=$computedAge, existing=${existing?.age}',
      );
    }

    if (apiAge > 0) return apiAge;
    if (computedAge > 0) return computedAge;
    return existing?.age ?? 0;
  }

  List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return const [];
  }

  List<String>? _parseNullableStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return null;
  }

  ChildProfile? _mergeChildProfileFromApi(
    Map<String, dynamic> data, {
    ChildProfile? existing,
    required String parentId,
    String? parentEmail,
  }) {
    final childId = _parseChildId(data);
    if (childId == null || childId.isEmpty) return null;

    final now = DateTime.now();
    final apiName = data['name']?.toString().trim();
    final resolvedName = (apiName != null && apiName.isNotEmpty)
        ? apiName
        : (existing?.name ?? childId);
    final age = _resolveAgeFromApi(data, existing);
    final existingLevel = existing?.level ?? 0;
    final level = existingLevel > 0 ? existingLevel : _parseInt(data['level'], 1);
    final avatar =
        existing?.avatar ?? data['avatar']?.toString() ?? 'avatar_1';
    final resolvedAvatarPath = existing?.avatarPath.isNotEmpty == true
        ? existing!.avatarPath
        : (avatar.startsWith('assets/')
            ? avatar
            : AppConstants.defaultChildAvatar);
    final picturePassword = (existing?.picturePassword.isNotEmpty ?? false)
        ? existing!.picturePassword
        : _parseStringList(data['picture_password']);
    final createdAt = existing?.createdAt ?? _parseDate(data['created_at'], now);
    final updatedAt = _parseDate(data['updated_at'], now);
    final lastSession =
        existing?.lastSession ?? _parseNullableDate(data['last_session']);

    return ChildProfile(
      id: childId,
      name: resolvedName,
      age: age,
      avatar: avatar,
      avatarPath: resolvedAvatarPath,
      interests: existing?.interests ?? _parseStringList(data['interests']),
      level: level,
      xp: existing?.xp ?? _parseInt(data['xp'], 0),
      streak: existing?.streak ?? _parseInt(data['streak'], 0),
      favorites: existing?.favorites ?? _parseStringList(data['favorites']),
      parentId: parentId,
      parentEmail: existing?.parentEmail ??
          parentEmail ??
          data['parent_email']?.toString(),
      picturePassword: picturePassword,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastSession: lastSession,
      totalTimeSpent:
          existing?.totalTimeSpent ?? _parseInt(data['total_time_spent'], 0),
      activitiesCompleted: existing?.activitiesCompleted ??
          _parseInt(data['activities_completed'], 0),
      currentMood: existing?.currentMood ?? data['current_mood']?.toString(),
      learningStyle:
          existing?.learningStyle ?? data['learning_style']?.toString(),
      specialNeeds:
          existing?.specialNeeds ?? _parseNullableStringList(data['special_needs']),
      accessibilityNeeds: existing?.accessibilityNeeds ??
          _parseNullableStringList(data['accessibility_needs']),
    );
  }

  Future<List<ChildProfile>> _loadChildrenForParent(String parentId) async {
    final repo = ref.read(childRepositoryProvider);
    final parentEmail = await ref.read(secureStorageProvider).getParentEmail();
    if (parentEmail != null && parentEmail.isNotEmpty) {
      await repo.linkChildrenToParent(
        parentId: parentId,
        parentEmail: parentEmail,
      );
    }
    final localChildren = await repo.getChildProfilesForParent(parentId);
    final childrenById = {
      for (final child in localChildren) child.id: child,
    };

    final token = await ref.read(secureStorageProvider).getAuthToken();
    if (token == null || token.startsWith('child_session_')) {
      return childrenById.values.toList();
    }

    final resolvedParentEmail = parentEmail;
    try {
      final response = await ref.read(networkServiceProvider).get<dynamic>(
        '/children',
      );
      final apiChildren = _extractChildrenList(response.data);
      for (final childData in apiChildren) {
        final childId = _parseChildId(childData);
        if (childId == null || childId.isEmpty) continue;
        final existing = await repo.getChildProfile(childId);
        final merged = _mergeChildProfileFromApi(
          childData,
          parentId: parentId,
          parentEmail: resolvedParentEmail,
          existing: existing,
        );
        if (merged == null) continue;
        childrenById[childId] = merged;
        if (existing == null) {
          await repo.createChildProfile(merged);
        } else {
          await repo.updateChildProfile(merged);
        }
      }
    } catch (_) {
      return childrenById.values.toList();
    }

    return childrenById.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
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
        body: SafeArea(
          child: FutureBuilder<String?>(
            future: ref.read(secureStorageProvider).getParentId(),
            builder: (context, parentIdSnapshot) {
              if (!parentIdSnapshot.hasData || parentIdSnapshot.data == null) {
                return Center(
                  child: CircularProgressIndicator(color: colors.primary),
                );
              }

              final parentId = parentIdSnapshot.data!;
              if (_childrenFuture == null || _cachedParentId != parentId) {
                _cachedParentId = parentId;
                _childrenFuture = _loadChildrenForParent(parentId);
              }

              return FutureBuilder<List<ChildProfile>>(
                future: _childrenFuture,
                builder: (context, childrenSnapshot) {
                  if (childrenSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: colors.primary),
                    );
                  }

                  final children = childrenSnapshot.data ?? [];

                  return CustomScrollView(
                    slivers: [
                      // App Bar
                      SliverAppBar(
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        elevation: 0,
                        floating: true,
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Parent Dashboard',
                              style: textTheme.titleLarge?.copyWith(
                                fontSize: AppConstants.largeFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Welcome back! Here\'s what\'s happening',
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: 14,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.settings),
                            color: colors.onSurface,
                            onPressed: () {
                              context.go('/parent/settings');
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications),
                            color: colors.onSurface,
                            onPressed: () {
                              context.go('/parent/notifications');
                            },
                          ),
                          Consumer(
                            builder: (context, ref, _) {
                              final themeMode =
                                  ref.watch(themeControllerProvider).mode;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: DashboardThemeSwitch(
                                  value: themeMode == ThemeMode.dark,
                                  onChanged: (isDark) {
                                    ref
                                        .read(themeControllerProvider.notifier)
                                        .setMode(
                                          isDark
                                              ? ThemeMode.dark
                                              : ThemeMode.light,
                                        );
                                  },
                                ),
                              );
                            },
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
                              const PlanStatusBanner(),
                              // Children Overview
                              _buildChildrenOverview(children),
                              const SizedBox(height: 24),
                              
                              // Quick Stats
                              _buildQuickStats(children),
                              const SizedBox(height: 24),
                              
                              // AI Insights
                              PlanGuard(
                                requiredTier: PlanTier.premium,
                                featureLabel: l10n.aiInsights,
                                child: _buildAiInsights(children),
                              ),
                              const SizedBox(height: 24),
                              
                              // Recent Activities
                              _buildRecentActivities(children),
                              const SizedBox(height: 24),
                              
                              // Weekly Progress Chart
                              _buildWeeklyProgressChart(children),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        
        // Floating Action Button
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            context.go('/parent/child-management');
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          icon: const Icon(Icons.add),
          label: const Text('Add Child'),
        ),
      ),
    );
  }

  Widget _buildChildrenOverview(List<ChildProfile> children) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    if (children.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(Icons.child_care, size: 64, color: colors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'No children added yet',
              style: textTheme.titleMedium?.copyWith(
                fontSize: AppConstants.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first child to get started',
              style: textTheme.bodySmall?.copyWith(
                fontSize: 14,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.go('/parent/child-management');
              },
              child: const Text('Add Child'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Children',
          style: textTheme.titleMedium?.copyWith(
            fontSize: AppConstants.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...children.map((child) => _buildChildCard(context, child)),
      ],
    );
  }

  Widget _buildChildCard(BuildContext context, ChildProfile child) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final ageLabel = child.age > 0 ? l10n.yearsOld(child.age) : '—';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          AvatarView(
            avatarId: child.avatar,
            avatarPath: child.avatarPath,
            radius: 30,
            backgroundColor: colors.primary.withValues(alpha: 0.2),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.name,
                  style: textTheme.titleSmall?.copyWith(
                    fontSize: AppConstants.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$ageLabel • Level ${child.level}',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 14,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip('${child.activitiesCompleted} activities', AppColors.success),
                    _buildInfoChip('${child.totalTimeSpent} min today', AppColors.info),
                    _buildInfoChip('${child.streak} day streak', AppColors.streakColor),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(List<ChildProfile> children) {
    if (children.isEmpty) {
      return const SizedBox();
    }
    final textTheme = Theme.of(context).textTheme;

    final totalTime = children.fold<int>(0, (sum, child) => sum + child.totalTimeSpent);
    final totalActivities =
        children.fold<int>(0, (sum, child) => sum + child.activitiesCompleted);
    final avgXp = children.isEmpty
        ? 0
        : (children.fold<int>(0, (sum, child) => sum + child.xp) ~/ children.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Overview',
          style: textTheme.titleMedium?.copyWith(
            fontSize: AppConstants.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Time',
                '$totalTime min',
                Icons.timer,
                AppColors.info,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Activities',
                '$totalActivities',
                Icons.check_circle,
                AppColors.success,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Avg XP',
                '$avgXp',
                Icons.star,
                AppColors.xpColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              fontSize: AppConstants.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAiInsights(List<ChildProfile> children) {
    if (children.isEmpty) {
      return const SizedBox();
    }
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.psychology, color: colors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'AI Insights',
                style: textTheme.titleMedium?.copyWith(
                  fontSize: AppConstants.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Text(
            _generateInsightMessage(children),
            style: textTheme.bodySmall?.copyWith(
              fontSize: 14,
              color: colors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          
          ElevatedButton(
            onPressed: () {
              context.go('/parent/reports');
            },
            child: const Text('View Detailed Report'),
          ),
        ],
      ),
    );
  }

  String _generateInsightMessage(List<ChildProfile> children) {
    if (children.isEmpty) return '';
    
    final names = children.map((c) => c.name).join(' and ');
    final totalActivities = children.fold<int>(0, (sum, child) => sum + child.activitiesCompleted);
    
    return '$names ${children.length > 1 ? 'are' : 'is'} showing great progress! '
           'Total of $totalActivities activities completed. '
           'Keep up the excellent work!';
  }

  Widget _buildRecentActivities(List<ChildProfile> children) {
    if (children.isEmpty) {
      return const SizedBox();
    }

    return FutureBuilder<List<ProgressRecord>>(
      future: _getRecentActivitiesForAllChildren(children),
      builder: (context, snapshot) {
        final activities = snapshot.data ?? [];
        final displayActivities = activities.take(4).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activities',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: AppConstants.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    context.go('/parent/reports');
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (displayActivities.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'No recent activities',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              )
            else
              Column(
                children: displayActivities.map((record) {
                  final child = children.firstWhere(
                    (c) => c.id == record.childId,
                    orElse: () => children.first,
                  );
                  return _buildActivityItem(
                    '${child.name} completed activity',
                    _formatTimeAgo(record.createdAt),
                    AppColors.educational,
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }

  Future<List<ProgressRecord>> _getRecentActivitiesForAllChildren(List<ChildProfile> children) async {
    final progressRepository = ref.read(progressRepositoryProvider);
    final allRecords = <ProgressRecord>[];
    
    for (final child in children) {
      final records = await progressRepository.getProgressForChild(child.id);
      allRecords.addAll(records);
    }
    
    // Sort by date, most recent first
    allRecords.sort((a, b) => b.date.compareTo(a.date));
    
    return allRecords.take(10).toList();
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    }
    return 'Just now';
  }

  Widget _buildActivityItem(String text, String time, Color color) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 14,
              ),
            ),
          ),
          Text(
            time,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgressChart(List<ChildProfile> children) {
    if (children.isEmpty) {
      return const SizedBox();
    }
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Placeholder data - in real app, would calculate from progress records
    final weekData = [3, 5, 2, 4, 6, 3, 2];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Progress',
            style: textTheme.titleMedium?.copyWith(
              fontSize: AppConstants.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Text(
                            days[value.toInt()],
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: weekData.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.toDouble(),
                        color: AppColors.educational,
                        width: 16,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
