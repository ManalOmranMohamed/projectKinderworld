// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProgressRecordImpl _$$ProgressRecordImplFromJson(Map<String, dynamic> json) =>
    _$ProgressRecordImpl(
      id: json['id'] as String,
      childId: json['childId'] as String,
      activityId: json['activityId'] as String,
      date: DateTime.parse(json['date'] as String),
      score: (json['score'] as num).toInt(),
      duration: (json['duration'] as num).toInt(),
      xpEarned: (json['xpEarned'] as num).toInt(),
      notes: json['notes'] as String?,
      completionStatus: json['completion_status'] as String,
      performanceMetrics: json['performance_metrics'] as Map<String, dynamic>?,
      aiFeedback: json['ai_feedback'] as String?,
      moodBefore: json['mood_before'] as String?,
      moodAfter: json['mood_after'] as String?,
      difficultyAdjusted: json['difficulty_adjusted'] as bool?,
      helpRequested: json['help_requested'] as bool?,
      parentApproved: json['parent_approved'] as bool?,
      syncStatus: json['sync_status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$ProgressRecordImplToJson(
        _$ProgressRecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'childId': instance.childId,
      'activityId': instance.activityId,
      'date': instance.date.toIso8601String(),
      'score': instance.score,
      'duration': instance.duration,
      'xpEarned': instance.xpEarned,
      'notes': instance.notes,
      'completion_status': instance.completionStatus,
      'performance_metrics': instance.performanceMetrics,
      'ai_feedback': instance.aiFeedback,
      'mood_before': instance.moodBefore,
      'mood_after': instance.moodAfter,
      'difficulty_adjusted': instance.difficultyAdjusted,
      'help_requested': instance.helpRequested,
      'parent_approved': instance.parentApproved,
      'sync_status': instance.syncStatus,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
