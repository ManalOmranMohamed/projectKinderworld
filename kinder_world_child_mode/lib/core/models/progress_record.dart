// Workaround for analyzer: allow JsonKey on Freezed constructor params
// (some analyzer versions report 'invalid_annotation_target')
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'progress_record.freezed.dart';
part 'progress_record.g.dart';

@freezed
class ProgressRecord with _$ProgressRecord {
  const factory ProgressRecord({
    required String id,
    required String childId,
    required String activityId,
    required DateTime date,
    required int score,
    required int duration,
    required int xpEarned,
    String? notes,
    @JsonKey(name: 'completion_status') required String completionStatus,
    @JsonKey(name: 'performance_metrics') Map<String, dynamic>? performanceMetrics,
    @JsonKey(name: 'ai_feedback') String? aiFeedback,
    @JsonKey(name: 'mood_before') String? moodBefore,
    @JsonKey(name: 'mood_after') String? moodAfter,
    @JsonKey(name: 'difficulty_adjusted') bool? difficultyAdjusted,
    @JsonKey(name: 'help_requested') bool? helpRequested,
    @JsonKey(name: 'parent_approved') bool? parentApproved,
    @JsonKey(name: 'sync_status') required String syncStatus,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _ProgressRecord;

  const ProgressRecord._();

  factory ProgressRecord.fromJson(Map<String, dynamic> json) => 
      _$ProgressRecordFromJson(json);

  // Check if activity was completed successfully
  bool get isCompletedSuccessfully {
    return completionStatus == CompletionStatus.completed && score >= 70;
  }

  // Get performance grade
  String get grade {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }

  // Get performance level
  String get performanceLevel {
    if (score >= 90) return 'Excellent';
    if (score >= 80) return 'Good';
    if (score >= 70) return 'Average';
    if (score >= 60) return 'Below Average';
    return 'Needs Improvement';
  }

  // Check if mood improved
  bool get moodImproved {
    if (moodBefore == null || moodAfter == null) return false;
    
    final moodValues = {
      'happy': 5,
      'excited': 4,
      'calm': 3,
      'tired': 2,
      'sad': 1,
      'angry': 0,
    };
    
    final beforeValue = moodValues[moodBefore] ?? 3;
    final afterValue = moodValues[moodAfter] ?? 3;
    
    return afterValue > beforeValue;
  }

  // Get time spent as formatted string
  String get formattedDuration {
    if (duration < 60) {
      return '$duration min';
    } else {
      final hours = duration ~/ 60;
      final minutes = duration % 60;
      if (minutes == 0) {
        return '$hours hour${hours > 1 ? 's' : ''}';
      } else {
        return '$hours hour${hours > 1 ? 's' : ''} $minutes min';
      }
    }
  }

  // Check if record needs to be synced
  bool get needsSync {
    return syncStatus == SyncStatus.pending || 
           syncStatus == SyncStatus.failed;
  }

  // Get engagement score based on various factors
  double get engagementScore {
    double score = 0.0;
    
    // Base score from completion
    if (completionStatus == CompletionStatus.completed) {
      score += 0.4;
    } else if (completionStatus == CompletionStatus.partial) {
      score += 0.2;
    }
    
    // Score from performance
    score += (this.score / 100.0) * 0.3;
    
    // Score from duration (normalized)
    final normalizedDuration = (duration / 60.0).clamp(0.0, 2.0);
    score += normalizedDuration * 0.2;
    
    // Score from help requests (less help = higher engagement)
    if (helpRequested == false) {
      score += 0.1;
    }
    
    return score.clamp(0.0, 1.0);
  }
}

// Completion statuses
class CompletionStatus {
  static const String notStarted = 'not_started';
  static const String inProgress = 'in_progress';
  static const String completed = 'completed';
  static const String partial = 'partial';
  static const String abandoned = 'abandoned';
  
  static const List<String> all = [
    notStarted, inProgress, completed, partial, abandoned
  ];
}

// Sync statuses
class SyncStatus {
  static const String synced = 'synced';
  static const String pending = 'pending';
  static const String failed = 'failed';
  static const String inProgress = 'in_progress';
  
  static const List<String> all = [
    synced, pending, failed, inProgress
  ];
}

// Performance metrics keys
class PerformanceMetrics {
  static const String accuracy = 'accuracy';
  static const String speed = 'speed';
  static const String attention = 'attention';
  static const String creativity = 'creativity';
  static const String problemSolving = 'problem_solving';
  static const String collaboration = 'collaboration';
  static const String persistence = 'persistence';
  
  static const List<String> all = [
    accuracy, speed, attention, creativity, 
    problemSolving, collaboration, persistence
  ];
}