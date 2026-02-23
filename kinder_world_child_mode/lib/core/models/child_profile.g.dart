// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChildProfileImpl _$$ChildProfileImplFromJson(Map<String, dynamic> json) =>
    _$ChildProfileImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      age: (json['age'] as num).toInt(),
      avatar: json['avatar'] as String,
      interests:
          (json['interests'] as List<dynamic>).map((e) => e as String).toList(),
      level: (json['level'] as num).toInt(),
      xp: (json['xp'] as num).toInt(),
      streak: (json['streak'] as num).toInt(),
      favorites:
          (json['favorites'] as List<dynamic>).map((e) => e as String).toList(),
      parentId: json['parentId'] as String,
      parentEmail: json['parent_email'] as String?,
      picturePassword: (json['picture_password'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastSession: json['last_session'] == null
          ? null
          : DateTime.parse(json['last_session'] as String),
      totalTimeSpent: (json['total_time_spent'] as num).toInt(),
      activitiesCompleted: (json['activities_completed'] as num).toInt(),
      currentMood: json['current_mood'] as String?,
      learningStyle: json['learning_style'] as String?,
      specialNeeds: (json['special_needs'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      accessibilityNeeds: (json['accessibility_needs'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      avatarPath:
          json['avatar_path'] as String? ?? AppConstants.defaultChildAvatar,
    );

Map<String, dynamic> _$$ChildProfileImplToJson(_$ChildProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'age': instance.age,
      'avatar': instance.avatar,
      'interests': instance.interests,
      'level': instance.level,
      'xp': instance.xp,
      'streak': instance.streak,
      'favorites': instance.favorites,
      'parentId': instance.parentId,
      'parent_email': instance.parentEmail,
      'picture_password': instance.picturePassword,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'last_session': instance.lastSession?.toIso8601String(),
      'total_time_spent': instance.totalTimeSpent,
      'activities_completed': instance.activitiesCompleted,
      'current_mood': instance.currentMood,
      'learning_style': instance.learningStyle,
      'special_needs': instance.specialNeeds,
      'accessibility_needs': instance.accessibilityNeeds,
      'avatar_path': instance.avatarPath,
    };
