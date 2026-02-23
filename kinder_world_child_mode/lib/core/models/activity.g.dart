// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActivityImpl _$$ActivityImplFromJson(Map<String, dynamic> json) =>
    _$ActivityImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      type: json['type'] as String,
      aspect: json['aspect'] as String,
      ageRange:
          (json['ageRange'] as List<dynamic>).map((e) => e as String).toList(),
      difficulty: json['difficulty'] as String,
      duration: (json['duration'] as num).toInt(),
      xpReward: (json['xpReward'] as num).toInt(),
      thumbnailUrl: json['thumbnailUrl'] as String,
      contentUrl: json['contentUrl'] as String?,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      learningObjectives: (json['learningObjectives'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      instructions: json['instructions'] as String?,
      materialsNeeded: (json['materialsNeeded'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isOfflineAvailable: json['is_offline_available'] as bool,
      isPremium: json['is_premium'] as bool,
      parentApprovalRequired: json['parent_approval_required'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      completionRate: (json['completion_rate'] as num?)?.toDouble(),
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      playCount: (json['play_count'] as num).toInt(),
    );

Map<String, dynamic> _$$ActivityImplToJson(_$ActivityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category': instance.category,
      'type': instance.type,
      'aspect': instance.aspect,
      'ageRange': instance.ageRange,
      'difficulty': instance.difficulty,
      'duration': instance.duration,
      'xpReward': instance.xpReward,
      'thumbnailUrl': instance.thumbnailUrl,
      'contentUrl': instance.contentUrl,
      'tags': instance.tags,
      'learningObjectives': instance.learningObjectives,
      'instructions': instance.instructions,
      'materialsNeeded': instance.materialsNeeded,
      'is_offline_available': instance.isOfflineAvailable,
      'is_premium': instance.isPremium,
      'parent_approval_required': instance.parentApprovalRequired,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'completion_rate': instance.completionRate,
      'average_rating': instance.averageRating,
      'play_count': instance.playCount,
    };
