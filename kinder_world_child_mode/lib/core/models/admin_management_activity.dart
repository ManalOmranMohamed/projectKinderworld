import 'package:kinder_world/core/models/admin_audit_log.dart';

class AdminUserActivitySummary {
  const AdminUserActivitySummary({
    required this.childCount,
    required this.notificationCount,
    required this.supportTicketCount,
    this.lastUpdatedAt,
  });

  final int childCount;
  final int notificationCount;
  final int supportTicketCount;
  final String? lastUpdatedAt;

  factory AdminUserActivitySummary.fromJson(Map<String, dynamic> json) {
    return AdminUserActivitySummary(
      childCount: _asInt(json['child_count']),
      notificationCount: _asInt(json['notification_count']),
      supportTicketCount: _asInt(json['support_ticket_count']),
      lastUpdatedAt: _asString(json['last_updated_at']),
    );
  }
}

class AdminUserNotificationPreview {
  const AdminUserNotificationPreview({
    required this.id,
    required this.title,
    required this.type,
    required this.isRead,
    this.createdAt,
  });

  final int id;
  final String title;
  final String type;
  final bool isRead;
  final String? createdAt;

  factory AdminUserNotificationPreview.fromJson(Map<String, dynamic> json) {
    return AdminUserNotificationPreview(
      id: _asInt(json['id']),
      title: _asString(json['title']) ?? '',
      type: _asString(json['type']) ?? '',
      isRead: _asBool(json['is_read']),
      createdAt: _asString(json['created_at']),
    );
  }
}

class AdminUserSupportTicketPreview {
  const AdminUserSupportTicketPreview({
    required this.id,
    required this.subject,
    this.email,
    this.createdAt,
  });

  final int id;
  final String subject;
  final String? email;
  final String? createdAt;

  factory AdminUserSupportTicketPreview.fromJson(Map<String, dynamic> json) {
    return AdminUserSupportTicketPreview(
      id: _asInt(json['id']),
      subject: _asString(json['subject']) ?? '',
      email: _asString(json['email']),
      createdAt: _asString(json['created_at']),
    );
  }
}

class AdminUserActivityDetails {
  const AdminUserActivityDetails({
    required this.userId,
    required this.summary,
    required this.notifications,
    required this.supportTickets,
    required this.adminAudit,
  });

  final int userId;
  final AdminUserActivitySummary summary;
  final List<AdminUserNotificationPreview> notifications;
  final List<AdminUserSupportTicketPreview> supportTickets;
  final List<AdminAuditLog> adminAudit;

  factory AdminUserActivityDetails.fromJson(Map<String, dynamic> json) {
    return AdminUserActivityDetails(
      userId: _asInt(json['user_id']),
      summary: AdminUserActivitySummary.fromJson(_asMap(json['summary'])),
      notifications: _asMapList(json['notifications'])
          .map(AdminUserNotificationPreview.fromJson)
          .toList(),
      supportTickets: _asMapList(json['support_tickets'])
          .map(AdminUserSupportTicketPreview.fromJson)
          .toList(),
      adminAudit:
          _asMapList(json['admin_audit']).map(AdminAuditLog.fromJson).toList(),
    );
  }
}

class AdminChildProgressSummary {
  const AdminChildProgressSummary({
    required this.daysSinceProfileCreated,
    required this.profileActive,
    required this.auditEvents,
    this.lastUpdatedAt,
  });

  final int daysSinceProfileCreated;
  final bool profileActive;
  final int auditEvents;
  final String? lastUpdatedAt;

  factory AdminChildProgressSummary.fromJson(Map<String, dynamic> json) {
    return AdminChildProgressSummary(
      daysSinceProfileCreated: _asInt(json['days_since_profile_created']),
      profileActive: _asBool(json['profile_active'], fallback: true),
      auditEvents: _asInt(json['audit_events']),
      lastUpdatedAt: _asString(json['last_updated_at']),
    );
  }
}

class AdminChildMilestone {
  const AdminChildMilestone({
    required this.title,
    this.timestamp,
  });

  final String title;
  final String? timestamp;

  factory AdminChildMilestone.fromJson(Map<String, dynamic> json) {
    return AdminChildMilestone(
      title: _asString(json['title']) ?? '',
      timestamp: _asString(json['timestamp']),
    );
  }
}

class AdminChildProgressDetails {
  const AdminChildProgressDetails({
    required this.childId,
    required this.summary,
    required this.milestones,
    required this.auditEvents,
  });

  final int childId;
  final AdminChildProgressSummary summary;
  final List<AdminChildMilestone> milestones;
  final List<AdminAuditLog> auditEvents;

  factory AdminChildProgressDetails.fromJson(Map<String, dynamic> json) {
    return AdminChildProgressDetails(
      childId: _asInt(json['child_id']),
      summary: AdminChildProgressSummary.fromJson(_asMap(json['summary'])),
      milestones: _asMapList(json['milestones'])
          .map(AdminChildMilestone.fromJson)
          .toList(),
      auditEvents:
          _asMapList(json['audit_events']).map(AdminAuditLog.fromJson).toList(),
    );
  }
}

class AdminChildActivityEntry {
  const AdminChildActivityEntry({
    required this.type,
    this.title,
    this.body,
    this.action,
    this.createdAt,
    this.timestamp,
  });

  final String type;
  final String? title;
  final String? body;
  final String? action;
  final String? createdAt;
  final String? timestamp;

  bool get isAudit => type == 'audit';
  String? get displayTitle => title ?? action ?? type;
  String get displayTimestamp => createdAt ?? timestamp ?? '';

  factory AdminChildActivityEntry.fromJson(Map<String, dynamic> json) {
    return AdminChildActivityEntry(
      type: _asString(json['type']) ?? '',
      title: _asString(json['title']),
      body: _asString(json['body']),
      action: _asString(json['action']),
      createdAt: _asString(json['created_at']),
      timestamp: _asString(json['timestamp']),
    );
  }
}

class AdminChildActivityLog {
  const AdminChildActivityLog({
    required this.childId,
    required this.entries,
  });

  final int childId;
  final List<AdminChildActivityEntry> entries;

  factory AdminChildActivityLog.fromJson(Map<String, dynamic> json) {
    return AdminChildActivityLog(
      childId: _asInt(json['child_id']),
      entries: _asMapList(json['entries'])
          .map(AdminChildActivityEntry.fromJson)
          .toList(),
    );
  }
}

class AdminChildAiBuddyUsageMetrics {
  const AdminChildAiBuddyUsageMetrics({
    required this.sessionsCount,
    required this.messagesCount,
    required this.childMessagesCount,
    required this.assistantMessagesCount,
    required this.allowedCount,
    required this.refusalCount,
    required this.safeRedirectCount,
    this.lastSessionAt,
  });

  final int sessionsCount;
  final int messagesCount;
  final int childMessagesCount;
  final int assistantMessagesCount;
  final int allowedCount;
  final int refusalCount;
  final int safeRedirectCount;
  final String? lastSessionAt;

  factory AdminChildAiBuddyUsageMetrics.fromJson(Map<String, dynamic> json) {
    return AdminChildAiBuddyUsageMetrics(
      sessionsCount: _asInt(json['sessions_count']),
      messagesCount: _asInt(json['messages_count']),
      childMessagesCount: _asInt(json['child_messages_count']),
      assistantMessagesCount: _asInt(json['assistant_messages_count']),
      allowedCount: _asInt(json['allowed_count']),
      refusalCount: _asInt(json['refusal_count']),
      safeRedirectCount: _asInt(json['safe_redirect_count']),
      lastSessionAt: _asString(json['last_session_at']),
    );
  }
}

class AdminChildAiBuddyFlag {
  const AdminChildAiBuddyFlag({
    required this.messageId,
    this.occurredAt,
    this.classification,
    this.topic,
    this.reason,
    this.action,
  });

  final int messageId;
  final String? occurredAt;
  final String? classification;
  final String? topic;
  final String? reason;
  final String? action;

  factory AdminChildAiBuddyFlag.fromJson(Map<String, dynamic> json) {
    return AdminChildAiBuddyFlag(
      messageId: _asInt(json['message_id']),
      occurredAt: _asString(json['occurred_at']),
      classification: _asString(json['classification']),
      topic: _asString(json['topic']),
      reason: _asString(json['reason']),
      action: _asString(json['action']),
    );
  }
}

class AdminChildAiBuddySummary {
  const AdminChildAiBuddySummary({
    required this.childId,
    required this.childName,
    required this.visibilityMode,
    required this.transcriptAccess,
    required this.parentSummary,
    required this.usageMetrics,
    required this.recentFlags,
  });

  final int childId;
  final String childName;
  final String visibilityMode;
  final bool transcriptAccess;
  final String parentSummary;
  final AdminChildAiBuddyUsageMetrics usageMetrics;
  final List<AdminChildAiBuddyFlag> recentFlags;

  factory AdminChildAiBuddySummary.fromJson(Map<String, dynamic> json) {
    return AdminChildAiBuddySummary(
      childId: _asInt(json['child_id']),
      childName: _asString(json['child_name']) ?? '',
      visibilityMode: _asString(json['visibility_mode']) ?? '',
      transcriptAccess: _asBool(json['transcript_access']),
      parentSummary: _asString(json['parent_summary']) ?? '',
      usageMetrics: AdminChildAiBuddyUsageMetrics.fromJson(
        _asMap(json['usage_metrics']),
      ),
      recentFlags: _asMapList(json['recent_flags'])
          .map(AdminChildAiBuddyFlag.fromJson)
          .toList(),
    );
  }
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return const <String, dynamic>{};
}

List<Map<String, dynamic>> _asMapList(Object? value) {
  if (value is! List) {
    return const <Map<String, dynamic>>[];
  }
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

String? _asString(Object? value) {
  final text = value?.toString();
  if (text == null || text.isEmpty || text == 'null') {
    return null;
  }
  return text;
}

int _asInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool _asBool(Object? value, {bool fallback = false}) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  final text = value?.toString().trim().toLowerCase();
  if (text == 'true') {
    return true;
  }
  if (text == 'false') {
    return false;
  }
  return fallback;
}
