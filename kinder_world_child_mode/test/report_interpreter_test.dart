import 'package:flutter_test/flutter_test.dart';
import 'package:kinder_world/core/models/child_profile.dart';
import 'package:kinder_world/core/models/progress_record.dart';
import 'package:kinder_world/features/parent_mode/reports/report_interpreter.dart';
import 'package:kinder_world/features/parent_mode/reports/report_models.dart';

ChildProfile _child({
  int activitiesCompleted = 2,
  int totalTimeSpent = 25,
  String? currentMood = 'happy',
}) {
  return ChildProfile(
    id: 'child-1',
    name: 'Dana',
    age: 7,
    avatar: 'assets/images/avatars/av1.png',
    interests: const ['math'],
    level: 2,
    xp: 250,
    streak: 6,
    favorites: const [],
    parentId: 'parent-1',
    parentEmail: 'parent@example.com',
    picturePassword: const ['cat', 'dog', 'apple'],
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 2),
    totalTimeSpent: totalTimeSpent,
    activitiesCompleted: activitiesCompleted,
    currentMood: currentMood,
    avatarPath: 'assets/images/avatars/av1.png',
  );
}

ProgressRecord _record({
  required String id,
  required String activityId,
  required DateTime date,
  required int score,
  required int duration,
  required int xpEarned,
  String completionStatus = CompletionStatus.completed,
  String? moodAfter,
  String? notes,
}) {
  return ProgressRecord(
    id: id,
    childId: 'child-1',
    activityId: activityId,
    date: date,
    score: score,
    duration: duration,
    xpEarned: xpEarned,
    notes: notes,
    completionStatus: completionStatus,
    moodAfter: moodAfter,
    syncStatus: SyncStatus.pending,
    createdAt: date,
    updatedAt: date,
  );
}

void main() {
  const interpreter = ParentReportInterpreter();

  test('interpreter produces positive insights for consistent progress', () {
    final now = DateTime.now();
    final report = ChildReportData(
      child: _child(),
      period: ReportPeriod.week,
      filteredRecords: [
        _record(
          id: '1',
          activityId: 'lesson_math_1',
          date: now.subtract(const Duration(days: 1)),
          score: 95,
          duration: 15,
          xpEarned: 40,
          moodAfter: 'happy',
        ),
        _record(
          id: '2',
          activityId: 'lesson_science_1',
          date: now.subtract(const Duration(days: 2)),
          score: 89,
          duration: 12,
          xpEarned: 35,
          moodAfter: 'happy',
        ),
      ],
      dailyPoints: [
        ReportDailyPoint(
          date: now.subtract(const Duration(days: 6)),
          activitiesCompleted: 1,
          lessonsCompleted: 1,
          screenTimeMinutes: 10,
        ),
        ReportDailyPoint(
          date: now.subtract(const Duration(days: 5)),
          activitiesCompleted: 0,
          lessonsCompleted: 0,
          screenTimeMinutes: 0,
        ),
        ReportDailyPoint(
          date: now.subtract(const Duration(days: 4)),
          activitiesCompleted: 1,
          lessonsCompleted: 1,
          screenTimeMinutes: 12,
        ),
        ReportDailyPoint(
          date: now.subtract(const Duration(days: 3)),
          activitiesCompleted: 0,
          lessonsCompleted: 0,
          screenTimeMinutes: 0,
        ),
        ReportDailyPoint(
          date: now.subtract(const Duration(days: 2)),
          activitiesCompleted: 1,
          lessonsCompleted: 1,
          screenTimeMinutes: 15,
        ),
        ReportDailyPoint(
          date: now.subtract(const Duration(days: 1)),
          activitiesCompleted: 0,
          lessonsCompleted: 0,
          screenTimeMinutes: 0,
        ),
        ReportDailyPoint(
          date: now,
          activitiesCompleted: 1,
          lessonsCompleted: 1,
          screenTimeMinutes: 14,
        ),
      ],
      totalActivitiesCompleted: 4,
      totalSessions: 4,
      totalLessonsCompleted: 4,
      totalScreenTimeMinutes: 51,
      averageScore: 92,
      completionRate: 0.9,
      topContentType: 'lessons',
      moodCounts: const {'happy': 3},
      currentMood: 'happy',
      achievements: const [],
      recentSessions: const [],
      usesRecordedSessions: true,
    );

    final interpretation = interpreter.interpret(report);

    expect(
      interpretation.insights.map((value) => value.type),
      containsAll(<ParentReportInsightType>[
        ParentReportInsightType.momentumStrong,
        ParentReportInsightType.completionStrong,
        ParentReportInsightType.scoreStrong,
      ]),
    );
    expect(
      interpretation.recommendations.first.type,
      ParentReportRecommendationType.usePreferredContentAsWarmup,
    );
  });

  test('interpreter recommends a restart when there is no recent activity', () {
    final report = ChildReportData(
      child:
          _child(activitiesCompleted: 0, totalTimeSpent: 0, currentMood: null),
      period: ReportPeriod.week,
      filteredRecords: const [],
      dailyPoints: const [],
      totalActivitiesCompleted: 0,
      totalSessions: 0,
      totalLessonsCompleted: 0,
      totalScreenTimeMinutes: 0,
      averageScore: 0,
      completionRate: 0,
      topContentType: null,
      moodCounts: const {},
      currentMood: null,
      achievements: const [],
      recentSessions: const [],
      usesRecordedSessions: false,
    );

    final interpretation = interpreter.interpret(report);

    expect(interpretation.insights.single.type,
        ParentReportInsightType.noRecentActivity);
    expect(
      interpretation.recommendations.map((value) => value.type),
      containsAll(<ParentReportRecommendationType>[
        ParentReportRecommendationType.startShortSession,
        ParentReportRecommendationType.setSimpleRoutine,
      ]),
    );
  });

  test('interpreter hides preference and mood insights when evidence is thin',
      () {
    final now = DateTime.now();
    final report = ChildReportData(
      child: _child(
          activitiesCompleted: 1, totalTimeSpent: 12, currentMood: 'happy'),
      period: ReportPeriod.week,
      filteredRecords: [
        _record(
          id: '1',
          activityId: 'lesson_math_1',
          date: now.subtract(const Duration(days: 1)),
          score: 96,
          duration: 12,
          xpEarned: 30,
          moodAfter: 'happy',
        ),
      ],
      dailyPoints: [
        ReportDailyPoint(
          date: now.subtract(const Duration(days: 1)),
          activitiesCompleted: 1,
          lessonsCompleted: 1,
          screenTimeMinutes: 12,
        ),
      ],
      totalActivitiesCompleted: 1,
      totalSessions: 1,
      totalLessonsCompleted: 1,
      totalScreenTimeMinutes: 12,
      averageScore: 96,
      completionRate: 1,
      topContentType: 'lessons',
      moodCounts: const {'happy': 1},
      currentMood: 'happy',
      achievements: const [],
      recentSessions: const [],
      usesRecordedSessions: true,
    );

    final interpretation = interpreter.interpret(report);

    expect(
      interpretation.insights.map((value) => value.type),
      isNot(contains(ParentReportInsightType.contentPreference)),
    );
    expect(
      interpretation.insights.map((value) => value.type),
      isNot(contains(ParentReportInsightType.moodPositive)),
    );
    expect(
      interpretation.insights.map((value) => value.type),
      isNot(contains(ParentReportInsightType.scoreStrong)),
    );
    expect(
      interpretation.insights.map((value) => value.type),
      isNot(contains(ParentReportInsightType.completionStrong)),
    );
    expect(
      interpretation.recommendations.map((value) => value.type),
      isNot(
        contains(
          ParentReportRecommendationType.usePreferredContentAsWarmup,
        ),
      ),
    );
  });
}
