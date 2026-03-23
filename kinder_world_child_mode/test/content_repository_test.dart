import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kinder_world/core/models/activity.dart';
import 'package:kinder_world/core/models/child_profile.dart';
import 'package:kinder_world/core/repositories/content_repository.dart';
import 'package:logger/logger.dart';

class _MemoryBox implements Box<dynamic> {
  final Map<dynamic, dynamic> _store = <dynamic, dynamic>{};

  void seed(dynamic key, dynamic value) {
    _store[key] = value;
  }

  @override
  Iterable<dynamic> get keys => _store.keys;

  @override
  dynamic get(dynamic key, {dynamic defaultValue}) {
    return _store.containsKey(key) ? _store[key] : defaultValue;
  }

  @override
  Future<void> put(dynamic key, dynamic value) async {
    _store[key] = value;
  }

  @override
  Future<void> putAll(Map<dynamic, dynamic> entries) async {
    _store.addAll(entries);
  }

  @override
  Future<void> delete(dynamic key) async {
    _store.remove(key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Activity _activity({
  required String id,
  required String title,
  required String category,
  required String type,
  required String aspect,
  required String difficulty,
  required List<String> ageRange,
  required List<String> tags,
  required int playCount,
  required DateTime createdAt,
  bool isOfflineAvailable = false,
  bool isPremium = false,
  double? averageRating,
}) {
  return Activity(
    id: id,
    title: title,
    description: '$title description',
    category: category,
    type: type,
    aspect: aspect,
    ageRange: ageRange,
    difficulty: difficulty,
    duration: 15,
    xpReward: 20,
    thumbnailUrl: 'https://example.com/$id.png',
    tags: tags,
    learningObjectives: const ['focus', 'practice'],
    isOfflineAvailable: isOfflineAvailable,
    isPremium: isPremium,
    parentApprovalRequired: false,
    createdAt: createdAt,
    updatedAt: createdAt,
    averageRating: averageRating,
    playCount: playCount,
  );
}

ChildProfile _child({
  required int age,
  required int level,
  required List<String> interests,
}) {
  final now = DateTime.utc(2026, 1, 1);
  return ChildProfile(
    id: 'child-1',
    name: 'Mila',
    age: age,
    avatar: 'assets/images/avatars/av1.png',
    interests: interests,
    level: level,
    xp: 120,
    streak: 3,
    favorites: const [],
    parentId: 'parent-1',
    picturePassword: const ['sun', 'moon', 'tree'],
    createdAt: now,
    updatedAt: now,
    totalTimeSpent: 0,
    activitiesCompleted: 0,
  );
}

void main() {
  group('ContentRepository', () {
    late _MemoryBox box;
    late ContentRepository repository;
    late Activity mathLesson;
    late Activity readingQuiz;
    late Activity storyGame;

    setUp(() {
      box = _MemoryBox();
      repository = ContentRepository(
        activityBox: box,
        logger: Logger(),
      );

      mathLesson = _activity(
        id: 'math-lesson',
        title: 'Math Garden',
        category: 'mathematics',
        type: 'lesson',
        aspect: 'educational',
        difficulty: 'easy',
        ageRange: const ['6-8'],
        tags: const ['numbers', 'math', 'garden'],
        playCount: 8,
        createdAt: DateTime.utc(2026, 1, 10),
        averageRating: 4.5,
      );
      readingQuiz = _activity(
        id: 'reading-quiz',
        title: 'Story Quiz',
        category: 'reading',
        type: 'quiz',
        aspect: 'skillful',
        difficulty: 'medium',
        ageRange: const ['8', '9'],
        tags: const ['story', 'reading'],
        playCount: 3,
        createdAt: DateTime.utc(2026, 1, 11),
        isOfflineAvailable: true,
      );
      storyGame = _activity(
        id: 'story-game',
        title: 'Story Builder',
        category: 'stories',
        type: 'game',
        aspect: 'entertaining',
        difficulty: 'beginner',
        ageRange: const ['5-7'],
        tags: const ['story', 'creative'],
        playCount: 12,
        createdAt: DateTime.utc(2026, 1, 12),
        isPremium: true,
        averageRating: 5,
      );
    });

    test('getAllActivities parses json payloads and skips invalid records', () async {
      box.seed(mathLesson.id, jsonEncode(mathLesson.toJson()));
      box.seed(readingQuiz.id, readingQuiz.toJson());
      box.seed('broken', '{not-valid-json');

      final items = await repository.getAllActivities();

      expect(items.map((item) => item.id), containsAll(<String>[
        mathLesson.id,
        readingQuiz.id,
      ]));
      expect(items, hasLength(2));
    });

    test('save, fetch, delete, and save many activities work as expected', () async {
      final saved = await repository.saveActivity(mathLesson);
      final fetched = await repository.getActivity(mathLesson.id);

      expect(saved?.id, mathLesson.id);
      expect(fetched?.title, mathLesson.title);

      final savedMany = await repository.saveActivities(<Activity>[
        readingQuiz,
        storyGame,
      ]);
      expect(savedMany, isTrue);

      final all = await repository.getAllActivities();
      expect(all, hasLength(3));

      final deleted = await repository.deleteActivity(readingQuiz.id);
      expect(deleted, isTrue);
      expect(await repository.getActivity(readingQuiz.id), isNull);
    });

    test('filters, search, popular, and recent views return matching activities', () async {
      await repository.saveActivities(<Activity>[
        mathLesson,
        readingQuiz,
        storyGame,
      ]);

      expect(
        (await repository.getActivitiesByCategory('reading')).single.id,
        readingQuiz.id,
      );
      expect(
        (await repository.getActivitiesByType('game')).single.id,
        storyGame.id,
      );
      expect(
        (await repository.getActivitiesByAspect('educational')).single.id,
        mathLesson.id,
      );
      expect(
        (await repository.getActivitiesByDifficulty('medium')).single.id,
        readingQuiz.id,
      );
      expect(
        (await repository.searchActivities('story')).map((item) => item.id),
        containsAll(<String>[readingQuiz.id, storyGame.id]),
      );
      expect(
        (await repository.getOfflineActivities()).single.id,
        readingQuiz.id,
      );
      expect(
        (await repository.getPopularActivities(limit: 2)).first.id,
        storyGame.id,
      );
      expect(
        (await repository.getRecentlyAddedActivities(limit: 1)).single.id,
        storyGame.id,
      );
    });

    test('child recommendations and age filtering prefer suitable activities', () async {
      await repository.saveActivities(<Activity>[
        mathLesson,
        readingQuiz,
        storyGame,
      ]);
      final child = _child(
        age: 8,
        level: 2,
        interests: const ['story', 'math'],
      );

      final recommended = await repository.getRecommendedActivities(child);
      final allowed = await repository.getActivitiesForChild(child);

      expect(recommended, isNotEmpty);
      expect(recommended.first.id, mathLesson.id);
      expect(allowed.map((item) => item.id), containsAll(<String>[
        mathLesson.id,
        readingQuiz.id,
      ]));
      expect(allowed.map((item) => item.id), isNot(contains(storyGame.id)));
    });

    test('offline preparation, play count, sync, and stats update stored data', () async {
      await repository.saveActivities(<Activity>[
        mathLesson,
        readingQuiz,
        storyGame,
      ]);

      final downloaded = await repository.downloadForOffline(mathLesson.id);
      final incremented = await repository.incrementPlayCount(mathLesson.id);
      final beforeSync = await repository.getActivity(mathLesson.id);
      final synced = await repository.syncWithServer();
      final afterSync = await repository.getActivity(mathLesson.id);
      final stats = await repository.getContentStats();

      expect(downloaded, isTrue);
      expect(incremented, isTrue);
      expect(beforeSync?.isOfflineAvailable, isTrue);
      expect(beforeSync?.playCount, mathLesson.playCount + 1);
      expect(synced, isTrue);
      expect(afterSync?.updatedAt.isAfter(mathLesson.updatedAt), isTrue);
      expect(stats['totalActivities'], 3);
      expect((stats['byCategory'] as Map<String, int>)['mathematics'], 1);
      expect((stats['byType'] as Map<String, int>)['game'], 1);
      expect((stats['byAspect'] as Map<String, int>)['educational'], 1);
      expect(stats['offlineCount'], 2);
      expect(stats['premiumCount'], 1);
    });
  });
}
