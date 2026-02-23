import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kinder_world/core/constants/app_constants.dart';
import 'package:kinder_world/core/localization/app_localizations.dart';
import 'package:kinder_world/core/models/child_profile.dart';
import 'package:kinder_world/core/theme/app_colors.dart';
import 'package:kinder_world/core/widgets/avatar_view.dart';
import 'package:kinder_world/core/widgets/picture_password_row.dart';

class ParentChildProfileScreen extends StatelessWidget {
  const ParentChildProfileScreen({
    super.key,
    required this.child,
  });

  final ChildProfile child;

  static const Map<String, String> _avatarAssets = {
    'avatar_1': 'assets/images/avatars/boy1.png',
    'avatar_2': 'assets/images/avatars/boy2.png',
    'avatar_3': 'assets/images/avatars/boy3.png',
    'avatar_4': 'assets/images/avatars/girl1.png',
    'avatar_5': 'assets/images/avatars/girl2.png',
    'avatar_6': 'assets/images/avatars/girl3.png',
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(child.name),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAvatarCircle(
                avatarId: child.avatar,
                avatarPath: child.avatarPath,
                size: 96,
              ),
              const SizedBox(height: 10),
              PicturePasswordRow(
                picturePassword: child.picturePassword,
                size: 18,
                showPlaceholders: true,
              ),
              const SizedBox(height: 16),
              Text(
                child.name,
                style: textTheme.titleLarge?.copyWith(
                  fontSize: AppConstants.largeFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                child.age > 0
                    ? '${l10n.yearsOld(child.age)} - ${l10n.level} ${child.level}'
                    : '— - ${l10n.level} ${child.level}',
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 14,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  _buildStatChip(
                    '${child.activitiesCompleted} ${l10n.activities}',
                    AppColors.success,
                  ),
                  _buildStatChip(
                    '${child.totalTimeSpent} ${l10n.timeSpent}',
                    AppColors.info,
                  ),
                  _buildStatChip(
                    '${child.streak} ${l10n.dailyStreak}',
                    AppColors.streakColor,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (child.interests.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.childInterests,
                        style: textTheme.titleSmall?.copyWith(
                          fontSize: AppConstants.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: child.interests
                            .map((interest) => _buildInterestChip(interest))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      context.push('/parent/reports', extra: child.id),
                  icon: const Icon(Icons.pie_chart),
                  label: Text(l10n.activityReports),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarCircle({
    required String? avatarId,
    required String? avatarPath,
    required double size,
  }) {
    final resolvedAvatar = _avatarAssets[avatarId] ?? avatarPath;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      child: ClipOval(
        child: AvatarView(
          avatarId: avatarId,
          avatarPath: resolvedAvatar,
          radius: size / 2,
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildStatChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInterestChip(String interest) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        interest,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
