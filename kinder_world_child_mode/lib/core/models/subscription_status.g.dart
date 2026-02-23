// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubscriptionStatusImpl _$$SubscriptionStatusImplFromJson(
        Map<String, dynamic> json) =>
    _$SubscriptionStatusImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      planType: json['plan_type'] as String,
      status: json['status'] as String,
      trialStartDate: json['trial_start_date'] == null
          ? null
          : DateTime.parse(json['trial_start_date'] as String),
      trialEndDate: json['trial_end_date'] == null
          ? null
          : DateTime.parse(json['trial_end_date'] as String),
      subscriptionStartDate: json['subscription_start_date'] == null
          ? null
          : DateTime.parse(json['subscription_start_date'] as String),
      subscriptionEndDate: json['subscription_end_date'] == null
          ? null
          : DateTime.parse(json['subscription_end_date'] as String),
      autoRenew: json['auto_renew'] as bool,
      paymentMethod: json['payment_method'] as String?,
      lastPaymentDate: json['last_payment_date'] == null
          ? null
          : DateTime.parse(json['last_payment_date'] as String),
      nextPaymentDate: json['next_payment_date'] == null
          ? null
          : DateTime.parse(json['next_payment_date'] as String),
      paymentAmount: (json['payment_amount'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      childProfilesLimit: (json['child_profiles_limit'] as num).toInt(),
      features:
          (json['features'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$SubscriptionStatusImplToJson(
        _$SubscriptionStatusImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'plan_type': instance.planType,
      'status': instance.status,
      'trial_start_date': instance.trialStartDate?.toIso8601String(),
      'trial_end_date': instance.trialEndDate?.toIso8601String(),
      'subscription_start_date':
          instance.subscriptionStartDate?.toIso8601String(),
      'subscription_end_date': instance.subscriptionEndDate?.toIso8601String(),
      'auto_renew': instance.autoRenew,
      'payment_method': instance.paymentMethod,
      'last_payment_date': instance.lastPaymentDate?.toIso8601String(),
      'next_payment_date': instance.nextPaymentDate?.toIso8601String(),
      'payment_amount': instance.paymentAmount,
      'currency': instance.currency,
      'child_profiles_limit': instance.childProfilesLimit,
      'features': instance.features,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };
