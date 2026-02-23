// Workaround for analyzer: allow JsonKey on Freezed constructor params
// (some analyzer versions report 'invalid_annotation_target')
// ignore_for_file: invalid_annotation_target

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_status.freezed.dart';
part 'subscription_status.g.dart';

@freezed
class SubscriptionStatus with _$SubscriptionStatus {
  const factory SubscriptionStatus({
    required String id,
    required String userId,
    @JsonKey(name: 'plan_type') required String planType,
    @JsonKey(name: 'status') required String status,
    @JsonKey(name: 'trial_start_date') DateTime? trialStartDate,
    @JsonKey(name: 'trial_end_date') DateTime? trialEndDate,
    @JsonKey(name: 'subscription_start_date') DateTime? subscriptionStartDate,
    @JsonKey(name: 'subscription_end_date') DateTime? subscriptionEndDate,
    @JsonKey(name: 'auto_renew') required bool autoRenew,
    @JsonKey(name: 'payment_method') String? paymentMethod,
    @JsonKey(name: 'last_payment_date') DateTime? lastPaymentDate,
    @JsonKey(name: 'next_payment_date') DateTime? nextPaymentDate,
    @JsonKey(name: 'payment_amount') double? paymentAmount,
    @JsonKey(name: 'currency') String? currency,
    @JsonKey(name: 'child_profiles_limit') required int childProfilesLimit,
    @JsonKey(name: 'features') required List<String> features,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _SubscriptionStatus;

  const SubscriptionStatus._();

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) => 
      _$SubscriptionStatusFromJson(json);

  // Check if subscription is active
  bool get isActive {
    if (status == SubscriptionStatusValues.active) {
      if (subscriptionEndDate != null) {
        return DateTime.now().isBefore(subscriptionEndDate!);
      }
      return true;
    }
    return false;
  }

  // Check if trial is active
  bool get isTrialActive {
    if (trialStartDate == null || trialEndDate == null) return false;
    final now = DateTime.now();
    return now.isAfter(trialStartDate!) && now.isBefore(trialEndDate!);
  }

  // Check if trial has ended
  bool get isTrialEnded {
    if (trialEndDate == null) return false;
    return DateTime.now().isAfter(trialEndDate!);
  }

  // Get remaining trial days
  int get remainingTrialDays {
    if (trialEndDate == null) return 0;
    final difference = trialEndDate!.difference(DateTime.now()).inDays;
    return difference > 0 ? difference : 0;
  }

  // Get remaining subscription days
  int get remainingSubscriptionDays {
    if (subscriptionEndDate == null) return 0;
    final difference = subscriptionEndDate!.difference(DateTime.now()).inDays;
    return difference > 0 ? difference : 0;
  }

  // Check if subscription will expire soon (within 7 days)
  bool get isExpiringSoon {
    if (subscriptionEndDate == null) return false;
    final difference = subscriptionEndDate!.difference(DateTime.now()).inDays;
    return difference > 0 && difference <= 7;
  }

  // Check if payment is due
  bool get isPaymentDue {
    if (nextPaymentDate == null) return false;
    return DateTime.now().isAfter(nextPaymentDate!);
  }

  // Get trial duration in days
  int get trialDurationDays {
    if (trialStartDate == null || trialEndDate == null) return 0;
    return trialEndDate!.difference(trialStartDate!).inDays;
  }

  // Check if a feature is available
  bool hasFeature(String feature) {
    return features.contains(feature);
  }

  // Get all available features
  List<String> get availableFeatures {
    return List.from(features);
  }

  // Check if can add more child profiles
  bool canAddChildProfile(int currentCount) {
    return currentCount < childProfilesLimit;
  }

  // Get next billing date
  DateTime? get nextBillingDate {
    if (subscriptionStartDate == null) return null;
    
    final now = DateTime.now();
    if (nextPaymentDate != null) {
      return nextPaymentDate;
    }
    
    // Calculate based on plan type
    final startDate = subscriptionStartDate!;
    if (planType == SubscriptionPlanType.monthly) {
      // Find next month anniversary
      var nextDate = DateTime(startDate.year, startDate.month + 1, startDate.day);
      while (nextDate.isBefore(now)) {
        nextDate = DateTime(nextDate.year, nextDate.month + 1, nextDate.day);
      }
      return nextDate;
    } else if (planType == SubscriptionPlanType.yearly) {
      // Find next year anniversary
      var nextDate = DateTime(startDate.year + 1, startDate.month, startDate.day);
      while (nextDate.isBefore(now)) {
        nextDate = DateTime(nextDate.year + 1, nextDate.month, nextDate.day);
      }
      return nextDate;
    }
    
    return null;
  }
}

// Subscription plan types
class SubscriptionPlanType {
  static const String free = 'free';
  static const String trial = 'trial';
  static const String monthly = 'monthly';
  static const String yearly = 'yearly';
  static const String family = 'family';
  static const String educational = 'educational';
  
  static const List<String> all = [
    free, trial, monthly, yearly, family, educational
  ];
  
  static String getDisplayName(String planType) {
    switch (planType) {
      case free:
        return 'Free';
      case trial:
        return 'Free Trial';
      case monthly:
        return 'Monthly';
      case yearly:
        return 'Yearly';
      case family:
        return 'Family Plan';
      case educational:
        return 'Educational Plan';
      default:
        return planType;
    }
  }
}

// Subscription statuses
class SubscriptionStatusValues {
  static const String active = 'active';
  static const String canceled = 'canceled';
  static const String expired = 'expired';
  static const String pending = 'pending';
  static const String suspended = 'suspended';
  static const String trial = 'trial';
  
  static const List<String> all = [
    active, canceled, expired, pending, suspended, trial
  ];
  
  static String getDisplayName(String status) {
    switch (status) {
      case active:
        return 'Active';
      case canceled:
        return 'Canceled';
      case expired:
        return 'Expired';
      case pending:
        return 'Pending';
      case suspended:
        return 'Suspended';
      case trial:
        return 'Trial';
      default:
        return status;
    }
  }
  
  static Color getColor(String status) {
    switch (status) {
      case active:
        return const Color(0xFF66BB6A);
      case canceled:
        return const Color(0xFFEF5350);
      case expired:
        return const Color(0xFFFFA726);
      case pending:
        return const Color(0xFF42A5F5);
      case suspended:
        return const Color(0xFFAB47BC);
      case trial:
        return const Color(0xFF26C6DA);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}

// Subscription features
class SubscriptionFeatures {
  static const String unlimitedActivities = 'unlimited_activities';
  static const String advancedReports = 'advanced_reports';
  static const String aiInsights = 'ai_insights';
  static const String multipleProfiles = 'multiple_profiles';
  static const String offlineDownload = 'offline_download';
  static const String prioritySupport = 'priority_support';
  static const String advancedParentalControls = 'advanced_parental_controls';
  static const String customLearningPaths = 'custom_learning_paths';
  static const String progressExport = 'progress_export';
  static const String noAds = 'no_ads';
  
  static const List<String> all = [
    unlimitedActivities, advancedReports, aiInsights, multipleProfiles,
    offlineDownload, prioritySupport, advancedParentalControls,
    customLearningPaths, progressExport, noAds
  ];
  
  static String getDisplayName(String feature) {
    switch (feature) {
      case unlimitedActivities:
        return 'Unlimited Activities';
      case advancedReports:
        return 'Advanced Reports';
      case aiInsights:
        return 'AI Insights';
      case multipleProfiles:
        return 'Multiple Child Profiles';
      case offlineDownload:
        return 'Offline Downloads';
      case prioritySupport:
        return 'Priority Support';
      case advancedParentalControls:
        return 'Advanced Parental Controls';
      case customLearningPaths:
        return 'Custom Learning Paths';
      case progressExport:
        return 'Progress Export';
      case noAds:
        return 'No Advertisements';
      default:
        return feature;
    }
  }
}