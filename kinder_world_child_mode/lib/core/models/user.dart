// Workaround for analyzer: allow JsonKey on Freezed constructor params
// (some analyzer versions report 'invalid_annotation_target')
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String role,
    String? name,
    String? phone,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'subscription_status') String? subscriptionStatus,
    @JsonKey(name: 'trial_end_date') DateTime? trialEndDate,
  }) = _User;

  const User._();

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  // Check if user is a parent
  bool get isParent => role == 'parent';
  
  // Check if user is a child
  bool get isChild => role == 'child';
  
  // Check if user is an admin
  bool get isAdmin => role == 'admin';
  
  // Check if subscription is active
  bool get hasActiveSubscription {
    if (subscriptionStatus == 'active') return true;
    if (trialEndDate != null && trialEndDate!.isAfter(DateTime.now())) return true;
    return false;
  }
  
  // Check if trial is active
  bool get hasActiveTrial {
    return trialEndDate != null && trialEndDate!.isAfter(DateTime.now());
  }
  
  // Get remaining trial days
  int get remainingTrialDays {
    if (trialEndDate == null) return 0;
    final difference = trialEndDate!.difference(DateTime.now()).inDays;
    return difference > 0 ? difference : 0;
  }
}

// User roles
class UserRoles {
  static const String parent = 'parent';
  static const String child = 'child';
  static const String admin = 'admin';
}

// Subscription statuses
class SubscriptionStatus {
  static const String active = 'active';
  static const String expired = 'expired';
  static const String canceled = 'canceled';
  static const String trial = 'trial';
}