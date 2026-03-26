import 'package:kinder_world/features/parent_mode/reports/report_models.dart';

enum ParentReportInsightType {
  noRecentActivity,
  momentumStrong,
  momentumNeedsRoutine,
  completionStrong,
  completionNeedsSupport,
  scoreStrong,
  scoreNeedsReview,
  contentPreference,
  moodPositive,
  moodNeedsCheckIn,
}

enum ParentReportRecommendationType {
  startShortSession,
  setSimpleRoutine,
  chooseShorterActivities,
  reviewRecentLessons,
  usePreferredContentAsWarmup,
  checkMoodBeforeStarting,
  keepRoutineAndStretch,
}

enum ParentReportTone {
  positive,
  neutral,
  attention,
}

class ParentReportInsight {
  const ParentReportInsight({
    required this.type,
    required this.tone,
    this.primaryValue,
    this.secondaryValue,
    this.contentType,
    this.mood,
  });

  final ParentReportInsightType type;
  final ParentReportTone tone;
  final int? primaryValue;
  final int? secondaryValue;
  final String? contentType;
  final String? mood;
}

class ParentReportRecommendation {
  const ParentReportRecommendation({
    required this.type,
    this.contentType,
  });

  final ParentReportRecommendationType type;
  final String? contentType;
}

class ParentReportInterpretation {
  const ParentReportInterpretation({
    required this.insights,
    required this.recommendations,
  });

  final List<ParentReportInsight> insights;
  final List<ParentReportRecommendation> recommendations;
}

class ParentReportInterpreter {
  const ParentReportInterpreter();

  static const int _minimumPerformanceSessions = 2;
  static const int _minimumPreferenceSessions = 2;
  static const int _minimumMoodEntries = 2;

  ParentReportInterpretation interpret(ChildReportData report) {
    final insights = <ParentReportInsight>[];
    final recommendations = <ParentReportRecommendation>[];

    final totalDays = report.dailyPoints.isNotEmpty
        ? report.dailyPoints.length
        : report.period.days;
    final activeDays = report.dailyPoints
        .where((point) => point.activitiesCompleted > 0)
        .length;
    final evidenceSessions = report.filteredRecords.isNotEmpty
        ? report.filteredRecords.length
        : report.totalSessions;
    final completionPercent = (report.completionRate * 100).round();
    final scorePercent = report.averageScore.round();
    final dominantMood = _dominantMood(report);

    if (report.totalSessions == 0 || report.totalActivitiesCompleted == 0) {
      insights.add(
        const ParentReportInsight(
          type: ParentReportInsightType.noRecentActivity,
          tone: ParentReportTone.neutral,
        ),
      );
      recommendations.add(
        const ParentReportRecommendation(
          type: ParentReportRecommendationType.startShortSession,
        ),
      );
      recommendations.add(
        const ParentReportRecommendation(
          type: ParentReportRecommendationType.setSimpleRoutine,
        ),
      );
      return ParentReportInterpretation(
        insights: insights,
        recommendations: recommendations,
      );
    }

    final activeRatio = totalDays == 0 ? 0.0 : activeDays / totalDays;
    if (activeRatio >= 0.4) {
      insights.add(
        ParentReportInsight(
          type: ParentReportInsightType.momentumStrong,
          tone: ParentReportTone.positive,
          primaryValue: activeDays,
          secondaryValue: totalDays,
        ),
      );
    } else {
      insights.add(
        ParentReportInsight(
          type: ParentReportInsightType.momentumNeedsRoutine,
          tone: ParentReportTone.attention,
          primaryValue: activeDays,
          secondaryValue: totalDays,
        ),
      );
      recommendations.add(
        const ParentReportRecommendation(
          type: ParentReportRecommendationType.setSimpleRoutine,
        ),
      );
    }

    if (evidenceSessions >= _minimumPerformanceSessions &&
        report.completionRate >= 0.75) {
      insights.add(
        ParentReportInsight(
          type: ParentReportInsightType.completionStrong,
          tone: ParentReportTone.positive,
          primaryValue: completionPercent,
        ),
      );
    } else if (evidenceSessions >= _minimumPerformanceSessions &&
        report.completionRate > 0 &&
        report.completionRate < 0.6) {
      insights.add(
        ParentReportInsight(
          type: ParentReportInsightType.completionNeedsSupport,
          tone: ParentReportTone.attention,
          primaryValue: completionPercent,
        ),
      );
      recommendations.add(
        const ParentReportRecommendation(
          type: ParentReportRecommendationType.chooseShorterActivities,
        ),
      );
    }

    if (evidenceSessions >= _minimumPerformanceSessions &&
        report.averageScore >= 85) {
      insights.add(
        ParentReportInsight(
          type: ParentReportInsightType.scoreStrong,
          tone: ParentReportTone.positive,
          primaryValue: scorePercent,
        ),
      );
    } else if (evidenceSessions >= _minimumPerformanceSessions &&
        report.averageScore > 0 &&
        report.averageScore < 75) {
      insights.add(
        ParentReportInsight(
          type: ParentReportInsightType.scoreNeedsReview,
          tone: ParentReportTone.attention,
          primaryValue: scorePercent,
        ),
      );
      recommendations.add(
        const ParentReportRecommendation(
          type: ParentReportRecommendationType.reviewRecentLessons,
        ),
      );
    }

    if (_isNegativeMood(dominantMood)) {
      insights.add(
        ParentReportInsight(
          type: ParentReportInsightType.moodNeedsCheckIn,
          tone: ParentReportTone.neutral,
          mood: dominantMood,
        ),
      );
      recommendations.add(
        const ParentReportRecommendation(
          type: ParentReportRecommendationType.checkMoodBeforeStarting,
        ),
      );
    } else if (_isPositiveMood(dominantMood)) {
      insights.add(
        ParentReportInsight(
          type: ParentReportInsightType.moodPositive,
          tone: ParentReportTone.positive,
          mood: dominantMood,
        ),
      );
    }

    if (evidenceSessions >= _minimumPreferenceSessions &&
        report.topContentType != null &&
        report.topContentType!.isNotEmpty) {
      insights.add(
        ParentReportInsight(
          type: ParentReportInsightType.contentPreference,
          tone: ParentReportTone.neutral,
          contentType: report.topContentType,
        ),
      );
      recommendations.add(
        ParentReportRecommendation(
          type: ParentReportRecommendationType.usePreferredContentAsWarmup,
          contentType: report.topContentType,
        ),
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add(
        const ParentReportRecommendation(
          type: ParentReportRecommendationType.keepRoutineAndStretch,
        ),
      );
    }

    return ParentReportInterpretation(
      insights: _dedupeInsights(insights).take(3).toList(growable: false),
      recommendations: _dedupeRecommendations(recommendations)
          .take(2)
          .toList(growable: false),
    );
  }

  String? _dominantMood(ChildReportData report) {
    if (report.moodCounts.isNotEmpty) {
      final totalEntries = report.moodCounts.values.fold<int>(
        0,
        (sum, value) => sum + value,
      );
      if (totalEntries < _minimumMoodEntries) {
        return null;
      }
      final ordered = report.moodCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return ordered.first.key;
    }
    return null;
  }

  bool _isNegativeMood(String? mood) {
    return mood == 'tired' || mood == 'sad' || mood == 'angry';
  }

  bool _isPositiveMood(String? mood) {
    return mood == 'happy' || mood == 'excited' || mood == 'calm';
  }

  List<ParentReportInsight> _dedupeInsights(List<ParentReportInsight> values) {
    final seen = <ParentReportInsightType>{};
    final unique = <ParentReportInsight>[];
    for (final value in values) {
      if (seen.add(value.type)) {
        unique.add(value);
      }
    }
    return unique;
  }

  List<ParentReportRecommendation> _dedupeRecommendations(
    List<ParentReportRecommendation> values,
  ) {
    final seen = <ParentReportRecommendationType>{};
    final unique = <ParentReportRecommendation>[];
    for (final value in values) {
      if (seen.add(value.type)) {
        unique.add(value);
      }
    }
    return unique;
  }
}
