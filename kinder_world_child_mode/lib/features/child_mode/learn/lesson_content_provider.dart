import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kinder_world/core/models/activity.dart';
import 'package:kinder_world/core/providers/content_controller.dart';
import 'package:kinder_world/features/child_mode/learn/data/lesson_catalog.dart';

class LearnLessonContent {
  const LearnLessonContent({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.durationMinutes,
    required this.xpReward,
    required this.difficulty,
    required this.category,
  });

  final String id;
  final String title;
  final String description;
  final String content;
  final int durationMinutes;
  final int xpReward;
  final String difficulty;
  final String category;

  factory LearnLessonContent.fromActivity(Activity activity) {
    return LearnLessonContent(
      id: activity.id,
      title: activity.title,
      description: activity.description,
      content: activity.instructions?.trim().isNotEmpty == true
          ? activity.instructions!.trim()
          : activity.description,
      durationMinutes: activity.duration,
      xpReward: activity.xpReward,
      difficulty: activity.difficulty,
      category: activity.aspect,
    );
  }

  factory LearnLessonContent.fromBlueprint(LearnLessonBlueprint blueprint) {
    return LearnLessonContent(
      id: blueprint.id,
      title: blueprint.title,
      description: blueprint.description,
      content: blueprint.content,
      durationMinutes: blueprint.durationMinutes,
      xpReward: blueprint.xpReward,
      difficulty: blueprint.difficulty,
      category: blueprint.category,
    );
  }
}

final lessonContentProvider =
    FutureProvider.autoDispose.family<LearnLessonContent, String>(
  (ref, lessonId) async {
    final controller = ref.watch(contentControllerProvider.notifier);
    final activity = await controller.getActivity(lessonId);
    if (activity != null) {
      return LearnLessonContent.fromActivity(activity);
    }

    final blueprint = lessonBlueprintById(lessonId);
    if (blueprint != null) {
      return LearnLessonContent.fromBlueprint(blueprint);
    }

    throw StateError('Lesson not found: $lessonId');
  },
);
