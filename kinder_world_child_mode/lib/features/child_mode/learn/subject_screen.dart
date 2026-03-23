import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kinder_world/core/constants/app_constants.dart';
import 'package:kinder_world/core/localization/app_localizations.dart';
import 'package:kinder_world/core/models/progress_record.dart';
import 'package:kinder_world/core/navigation/app_navigation_controller.dart';
import 'package:kinder_world/core/providers/child_session_controller.dart';
import 'package:kinder_world/core/providers/progress_controller.dart';
import 'package:kinder_world/core/theme/theme_extensions.dart';
import 'package:kinder_world/core/widgets/child_safe_ui.dart';
import 'package:kinder_world/features/child_mode/learn/data/lesson_catalog.dart';
import 'package:kinder_world/router.dart';

class SubjectScreen extends ConsumerWidget {
  const SubjectScreen({
    super.key,
    required this.subject,
  });

  final String subject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final subjectColor = _getSubjectColor(context, subject);
    final onSubjectColor = subjectColor.onColor;

    final pathAsync = ref.watch(_subjectPathProvider(subject));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onSurface),
          onPressed: () => context.appBack(fallback: Routes.childLearn),
        ),
        title: Text(
          _getSubjectDisplayName(l10n, subject),
          style: textTheme.titleMedium?.copyWith(
            fontSize: AppConstants.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: pathAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: colors.error),
              ),
            ),
          ),
          data: (path) {
            final lessons = path.lessons;
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: subjectColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: onSubjectColor.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Icon(
                                _getSubjectIcon(subject),
                                size: 30,
                                color: onSubjectColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getSubjectDisplayName(l10n, subject),
                                    style: textTheme.titleLarge?.copyWith(
                                      fontSize: AppConstants.largeFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: onSubjectColor,
                                    ),
                                  ),
                                  Text(
                                    '${lessons.length} ${l10n.availableLessons.toLowerCase()}',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: onSubjectColor.withValues(
                                          alpha: 0.85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            l10n.levelsSubtitle,
                            style: textTheme.bodySmall?.copyWith(
                              color: onSubjectColor.withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: path.totalLessons == 0
                              ? 0
                              : path.completedLessons / path.totalLessons,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(999),
                          backgroundColor:
                              onSubjectColor.withValues(alpha: 0.22),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            onSubjectColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${l10n.lessonsCompletedLabel}: ${path.completedLessons}/${path.totalLessons}',
                            style: textTheme.bodySmall?.copyWith(
                              color: onSubjectColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (path.nextLesson != null)
                    _NextLessonCard(
                      lesson: path.nextLesson!,
                      onStart: () => context.go(
                        '${Routes.childLearn}/lesson/${path.nextLesson!.id}',
                      ),
                    ),
                  if (path.nextLesson != null) const SizedBox(height: 16),
                  Text(
                    l10n.availableLessons,
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: AppConstants.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: lessons.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final lesson = lessons[index];
                        return _LessonCard(
                          lesson: lesson,
                          levelNumber: index + 1,
                          onTap: () {
                            if (!lesson.isUnlocked) {
                              HapticFeedback.selectionClick();
                              final requirements = lesson
                                      .missingPrerequisites.isEmpty
                                  ? l10n.finishPreviousLevel
                                  : '${l10n.finishPreviousLevel}: ${lesson.missingPrerequisites.first}';
                              showChildFeedbackSnackBar(
                                context,
                                requirements,
                                success: false,
                              );
                              return;
                            }
                            HapticFeedback.lightImpact();
                            context.go(
                              '${Routes.childLearn}/lesson/${lesson.id}',
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getSubjectColor(BuildContext context, String value) {
    final childTheme = context.childTheme;
    final colors = Theme.of(context).colorScheme;
    switch (value) {
      case 'math':
        return childTheme.learning;
      case 'science':
        return childTheme.skill;
      case 'reading':
        return childTheme.kindness;
      case 'history':
        return childTheme.fun;
      case 'geography':
        return colors.secondary;
      default:
        return colors.primary;
    }
  }

  IconData _getSubjectIcon(String value) {
    switch (value) {
      case 'math':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'reading':
        return Icons.book;
      case 'history':
        return Icons.history_edu;
      case 'geography':
        return Icons.public;
      default:
        return Icons.school;
    }
  }

  String _getSubjectDisplayName(AppLocalizations l10n, String value) {
    switch (value) {
      case 'math':
        return l10n.mathematics;
      case 'science':
        return l10n.science;
      case 'reading':
        return l10n.reading;
      case 'history':
        return l10n.history;
      case 'geography':
        return l10n.geography;
      default:
        return value;
    }
  }
}

final _subjectPathProvider =
    FutureProvider.autoDispose.family<_SubjectPathData, String>(
  (ref, subject) async {
    final childId = ref.watch(currentChildIdProvider);
    final repo = ref.watch(progressRepositoryProvider);
    final completedActivityIds = <String>{};

    if (childId != null && childId.isNotEmpty) {
      final records = await repo.getProgressForChild(childId);
      for (final record in records) {
        if (record.completionStatus != CompletionStatus.completed) continue;
        completedActivityIds.add(record.activityId);
      }
    }

    final blueprints = lessonsForSubject(subject);
    final completedLessonIds = completedActivityIds
        .where((id) => id.startsWith('lesson_'))
        .map((id) => id.replaceFirst('lesson_', ''))
        .toSet();

    final byId = {for (final lesson in blueprints) lesson.id: lesson};
    final lessons = blueprints.map((lesson) {
      final completed = completedLessonIds.contains(lesson.id);
      final missingPrerequisites = lesson.prerequisites
          .where((id) => !completedLessonIds.contains(id))
          .map((id) => byId[id]?.title ?? id)
          .toList(growable: false);
      final unlocked = completed || missingPrerequisites.isEmpty;
      return _LessonProgress(
        id: lesson.id,
        title: lesson.title,
        description: lesson.description,
        durationMinutes: lesson.durationMinutes,
        difficulty: _difficultyFromString(lesson.difficulty),
        xpReward: lesson.xpReward,
        prerequisites: lesson.prerequisites,
        missingPrerequisites: missingPrerequisites,
        isCompleted: completed,
        isUnlocked: unlocked,
      );
    }).toList(growable: false);

    _LessonProgress? nextLesson;
    for (final lesson in lessons) {
      if (!lesson.isCompleted && lesson.isUnlocked) {
        nextLesson = lesson;
        break;
      }
    }

    final completedCount = lessons.where((lesson) => lesson.isCompleted).length;

    return _SubjectPathData(
      lessons: lessons,
      nextLesson: nextLesson,
      completedLessons: completedCount,
      totalLessons: lessons.length,
    );
  },
);

class _NextLessonCard extends StatelessWidget {
  const _NextLessonCard({
    required this.lesson,
    required this.onStart,
  });

  final _LessonProgress lesson;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final badgeColor = _difficultyColor(context, lesson.difficulty);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.flag, color: colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.continueLearning,
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  lesson.title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _MiniPill(
                      icon: Icons.access_time,
                      label: '${lesson.durationMinutes} min',
                    ),
                    _MiniPill(icon: Icons.star, label: '${lesson.xpReward} XP'),
                    _MiniPill(
                      icon: Icons.trending_up,
                      label: _difficultyLabel(l10n, lesson.difficulty),
                      color: badgeColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow_rounded, size: 20),
            label: Text(l10n.start),
            style: FilledButton.styleFrom(
              minimumSize: const Size(96, 52),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.lesson,
    required this.levelNumber,
    required this.onTap,
  });

  final _LessonProgress lesson;
  final int levelNumber;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final locked = !lesson.isUnlocked;
    final completed = lesson.isCompleted;
    final difficultyColor = _difficultyColor(context, lesson.difficulty);

    return Semantics(
      button: true,
      label:
          '${lesson.title}. ${completed ? l10n.complete : (locked ? l10n.lockedLabel : l10n.unlockedLabel)}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: locked
                ? colors.surfaceContainerHighest.withValues(alpha: 0.55)
                : colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: completed
                  ? context.successColor.withValues(alpha: 0.35)
                  : locked
                      ? colors.outlineVariant.withValues(alpha: 0.45)
                      : colors.primary.withValues(alpha: 0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PathStepIndicator(
                levelNumber: levelNumber,
                isCompleted: completed,
                isLocked: locked,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lesson.title,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: locked
                                  ? colors.onSurfaceVariant
                                  : colors.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusChip(
                          label: completed
                              ? l10n.complete
                              : (locked
                                  ? l10n.lockedLabel
                                  : l10n.unlockedLabel),
                          color: completed
                              ? context.successColor
                              : (locked ? colors.outline : colors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lesson.description,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MiniPill(
                          icon: Icons.access_time,
                          label: '${lesson.durationMinutes} min',
                        ),
                        _MiniPill(
                            icon: Icons.star, label: '${lesson.xpReward} XP'),
                        _MiniPill(
                          icon: Icons.trending_up,
                          label: _difficultyLabel(l10n, lesson.difficulty),
                          color: difficultyColor,
                        ),
                      ],
                    ),
                    if (lesson.missingPrerequisites.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${l10n.whatHappensNext}: ${lesson.missingPrerequisites.join(', ')}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                completed
                    ? Icons.check_circle
                    : locked
                        ? Icons.lock
                        : Icons.play_circle,
                color: completed
                    ? context.successColor
                    : locked
                        ? colors.outline
                        : colors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PathStepIndicator extends StatelessWidget {
  const _PathStepIndicator({
    required this.levelNumber,
    required this.isCompleted,
    required this.isLocked,
  });

  final int levelNumber;
  final bool isCompleted;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = isCompleted
        ? context.successColor
        : isLocked
            ? colors.outline
            : colors.primary;
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      alignment: Alignment.center,
      child: Text(
        '$levelNumber',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _MiniPill extends StatelessWidget {
  const _MiniPill({
    required this.icon,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tint = color ?? colors.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: tint),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: tint,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

Color _difficultyColor(BuildContext context, _Difficulty difficulty) {
  final childTheme = context.childTheme;
  switch (difficulty) {
    case _Difficulty.beginner:
      return childTheme.kindness;
    case _Difficulty.intermediate:
      return childTheme.learning;
    case _Difficulty.advanced:
      return childTheme.streak;
  }
}

String _difficultyLabel(AppLocalizations l10n, _Difficulty difficulty) {
  switch (difficulty) {
    case _Difficulty.beginner:
      return l10n.beginner;
    case _Difficulty.intermediate:
      return l10n.intermediate;
    case _Difficulty.advanced:
      return l10n.advanced;
  }
}

_Difficulty _difficultyFromString(String difficulty) {
  switch (difficulty) {
    case 'beginner':
      return _Difficulty.beginner;
    case 'advanced':
      return _Difficulty.advanced;
    default:
      return _Difficulty.intermediate;
  }
}

enum _Difficulty { beginner, intermediate, advanced }

class _LessonProgress {
  const _LessonProgress({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.difficulty,
    required this.xpReward,
    required this.prerequisites,
    required this.missingPrerequisites,
    required this.isCompleted,
    required this.isUnlocked,
  });

  final String id;
  final String title;
  final String description;
  final int durationMinutes;
  final _Difficulty difficulty;
  final int xpReward;
  final List<String> prerequisites;
  final List<String> missingPrerequisites;
  final bool isCompleted;
  final bool isUnlocked;
}

class _SubjectPathData {
  const _SubjectPathData({
    required this.lessons,
    required this.nextLesson,
    required this.completedLessons,
    required this.totalLessons,
  });

  final List<_LessonProgress> lessons;
  final _LessonProgress? nextLesson;
  final int completedLessons;
  final int totalLessons;
}
