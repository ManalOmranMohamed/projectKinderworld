// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationItemImpl _$$NotificationItemImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationItemImpl(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      recipientId: json['recipientId'] as String,
      recipientRole: json['recipientRole'] as String,
      relatedChildId: json['related_child_id'] as String?,
      relatedActivityId: json['related_activity_id'] as String?,
      isRead: json['is_read'] as bool,
      isSent: json['is_sent'] as bool,
      sentAt: json['sent_at'] == null
          ? null
          : DateTime.parse(json['sent_at'] as String),
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
      priority: json['priority'] as String,
      data: json['data'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
    );

Map<String, dynamic> _$$NotificationItemImplToJson(
        _$NotificationItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'body': instance.body,
      'recipientId': instance.recipientId,
      'recipientRole': instance.recipientRole,
      'related_child_id': instance.relatedChildId,
      'related_activity_id': instance.relatedActivityId,
      'is_read': instance.isRead,
      'is_sent': instance.isSent,
      'sent_at': instance.sentAt?.toIso8601String(),
      'read_at': instance.readAt?.toIso8601String(),
      'priority': instance.priority,
      'data': instance.data,
      'created_at': instance.createdAt.toIso8601String(),
      'expires_at': instance.expiresAt?.toIso8601String(),
    };
