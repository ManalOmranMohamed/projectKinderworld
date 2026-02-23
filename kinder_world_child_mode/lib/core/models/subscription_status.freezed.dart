// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SubscriptionStatus _$SubscriptionStatusFromJson(Map<String, dynamic> json) {
  return _SubscriptionStatus.fromJson(json);
}

/// @nodoc
mixin _$SubscriptionStatus {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'plan_type')
  String get planType => throw _privateConstructorUsedError;
  @JsonKey(name: 'status')
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'trial_start_date')
  DateTime? get trialStartDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'trial_end_date')
  DateTime? get trialEndDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'subscription_start_date')
  DateTime? get subscriptionStartDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'subscription_end_date')
  DateTime? get subscriptionEndDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'auto_renew')
  bool get autoRenew => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_method')
  String? get paymentMethod => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_payment_date')
  DateTime? get lastPaymentDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_payment_date')
  DateTime? get nextPaymentDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'payment_amount')
  double? get paymentAmount => throw _privateConstructorUsedError;
  @JsonKey(name: 'currency')
  String? get currency => throw _privateConstructorUsedError;
  @JsonKey(name: 'child_profiles_limit')
  int get childProfilesLimit => throw _privateConstructorUsedError;
  @JsonKey(name: 'features')
  List<String> get features => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this SubscriptionStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubscriptionStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionStatusCopyWith<SubscriptionStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionStatusCopyWith<$Res> {
  factory $SubscriptionStatusCopyWith(
          SubscriptionStatus value, $Res Function(SubscriptionStatus) then) =
      _$SubscriptionStatusCopyWithImpl<$Res, SubscriptionStatus>;
  @useResult
  $Res call(
      {String id,
      String userId,
      @JsonKey(name: 'plan_type') String planType,
      @JsonKey(name: 'status') String status,
      @JsonKey(name: 'trial_start_date') DateTime? trialStartDate,
      @JsonKey(name: 'trial_end_date') DateTime? trialEndDate,
      @JsonKey(name: 'subscription_start_date') DateTime? subscriptionStartDate,
      @JsonKey(name: 'subscription_end_date') DateTime? subscriptionEndDate,
      @JsonKey(name: 'auto_renew') bool autoRenew,
      @JsonKey(name: 'payment_method') String? paymentMethod,
      @JsonKey(name: 'last_payment_date') DateTime? lastPaymentDate,
      @JsonKey(name: 'next_payment_date') DateTime? nextPaymentDate,
      @JsonKey(name: 'payment_amount') double? paymentAmount,
      @JsonKey(name: 'currency') String? currency,
      @JsonKey(name: 'child_profiles_limit') int childProfilesLimit,
      @JsonKey(name: 'features') List<String> features,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class _$SubscriptionStatusCopyWithImpl<$Res, $Val extends SubscriptionStatus>
    implements $SubscriptionStatusCopyWith<$Res> {
  _$SubscriptionStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubscriptionStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? planType = null,
    Object? status = null,
    Object? trialStartDate = freezed,
    Object? trialEndDate = freezed,
    Object? subscriptionStartDate = freezed,
    Object? subscriptionEndDate = freezed,
    Object? autoRenew = null,
    Object? paymentMethod = freezed,
    Object? lastPaymentDate = freezed,
    Object? nextPaymentDate = freezed,
    Object? paymentAmount = freezed,
    Object? currency = freezed,
    Object? childProfilesLimit = null,
    Object? features = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      planType: null == planType
          ? _value.planType
          : planType // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      trialStartDate: freezed == trialStartDate
          ? _value.trialStartDate
          : trialStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      trialEndDate: freezed == trialEndDate
          ? _value.trialEndDate
          : trialEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      subscriptionStartDate: freezed == subscriptionStartDate
          ? _value.subscriptionStartDate
          : subscriptionStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      subscriptionEndDate: freezed == subscriptionEndDate
          ? _value.subscriptionEndDate
          : subscriptionEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      autoRenew: null == autoRenew
          ? _value.autoRenew
          : autoRenew // ignore: cast_nullable_to_non_nullable
              as bool,
      paymentMethod: freezed == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String?,
      lastPaymentDate: freezed == lastPaymentDate
          ? _value.lastPaymentDate
          : lastPaymentDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextPaymentDate: freezed == nextPaymentDate
          ? _value.nextPaymentDate
          : nextPaymentDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      paymentAmount: freezed == paymentAmount
          ? _value.paymentAmount
          : paymentAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      currency: freezed == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
      childProfilesLimit: null == childProfilesLimit
          ? _value.childProfilesLimit
          : childProfilesLimit // ignore: cast_nullable_to_non_nullable
              as int,
      features: null == features
          ? _value.features
          : features // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubscriptionStatusImplCopyWith<$Res>
    implements $SubscriptionStatusCopyWith<$Res> {
  factory _$$SubscriptionStatusImplCopyWith(_$SubscriptionStatusImpl value,
          $Res Function(_$SubscriptionStatusImpl) then) =
      __$$SubscriptionStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      @JsonKey(name: 'plan_type') String planType,
      @JsonKey(name: 'status') String status,
      @JsonKey(name: 'trial_start_date') DateTime? trialStartDate,
      @JsonKey(name: 'trial_end_date') DateTime? trialEndDate,
      @JsonKey(name: 'subscription_start_date') DateTime? subscriptionStartDate,
      @JsonKey(name: 'subscription_end_date') DateTime? subscriptionEndDate,
      @JsonKey(name: 'auto_renew') bool autoRenew,
      @JsonKey(name: 'payment_method') String? paymentMethod,
      @JsonKey(name: 'last_payment_date') DateTime? lastPaymentDate,
      @JsonKey(name: 'next_payment_date') DateTime? nextPaymentDate,
      @JsonKey(name: 'payment_amount') double? paymentAmount,
      @JsonKey(name: 'currency') String? currency,
      @JsonKey(name: 'child_profiles_limit') int childProfilesLimit,
      @JsonKey(name: 'features') List<String> features,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class __$$SubscriptionStatusImplCopyWithImpl<$Res>
    extends _$SubscriptionStatusCopyWithImpl<$Res, _$SubscriptionStatusImpl>
    implements _$$SubscriptionStatusImplCopyWith<$Res> {
  __$$SubscriptionStatusImplCopyWithImpl(_$SubscriptionStatusImpl _value,
      $Res Function(_$SubscriptionStatusImpl) _then)
      : super(_value, _then);

  /// Create a copy of SubscriptionStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? planType = null,
    Object? status = null,
    Object? trialStartDate = freezed,
    Object? trialEndDate = freezed,
    Object? subscriptionStartDate = freezed,
    Object? subscriptionEndDate = freezed,
    Object? autoRenew = null,
    Object? paymentMethod = freezed,
    Object? lastPaymentDate = freezed,
    Object? nextPaymentDate = freezed,
    Object? paymentAmount = freezed,
    Object? currency = freezed,
    Object? childProfilesLimit = null,
    Object? features = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$SubscriptionStatusImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      planType: null == planType
          ? _value.planType
          : planType // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      trialStartDate: freezed == trialStartDate
          ? _value.trialStartDate
          : trialStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      trialEndDate: freezed == trialEndDate
          ? _value.trialEndDate
          : trialEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      subscriptionStartDate: freezed == subscriptionStartDate
          ? _value.subscriptionStartDate
          : subscriptionStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      subscriptionEndDate: freezed == subscriptionEndDate
          ? _value.subscriptionEndDate
          : subscriptionEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      autoRenew: null == autoRenew
          ? _value.autoRenew
          : autoRenew // ignore: cast_nullable_to_non_nullable
              as bool,
      paymentMethod: freezed == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String?,
      lastPaymentDate: freezed == lastPaymentDate
          ? _value.lastPaymentDate
          : lastPaymentDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextPaymentDate: freezed == nextPaymentDate
          ? _value.nextPaymentDate
          : nextPaymentDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      paymentAmount: freezed == paymentAmount
          ? _value.paymentAmount
          : paymentAmount // ignore: cast_nullable_to_non_nullable
              as double?,
      currency: freezed == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String?,
      childProfilesLimit: null == childProfilesLimit
          ? _value.childProfilesLimit
          : childProfilesLimit // ignore: cast_nullable_to_non_nullable
              as int,
      features: null == features
          ? _value._features
          : features // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubscriptionStatusImpl extends _SubscriptionStatus {
  const _$SubscriptionStatusImpl(
      {required this.id,
      required this.userId,
      @JsonKey(name: 'plan_type') required this.planType,
      @JsonKey(name: 'status') required this.status,
      @JsonKey(name: 'trial_start_date') this.trialStartDate,
      @JsonKey(name: 'trial_end_date') this.trialEndDate,
      @JsonKey(name: 'subscription_start_date') this.subscriptionStartDate,
      @JsonKey(name: 'subscription_end_date') this.subscriptionEndDate,
      @JsonKey(name: 'auto_renew') required this.autoRenew,
      @JsonKey(name: 'payment_method') this.paymentMethod,
      @JsonKey(name: 'last_payment_date') this.lastPaymentDate,
      @JsonKey(name: 'next_payment_date') this.nextPaymentDate,
      @JsonKey(name: 'payment_amount') this.paymentAmount,
      @JsonKey(name: 'currency') this.currency,
      @JsonKey(name: 'child_profiles_limit') required this.childProfilesLimit,
      @JsonKey(name: 'features') required final List<String> features,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt})
      : _features = features,
        super._();

  factory _$SubscriptionStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscriptionStatusImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  @JsonKey(name: 'plan_type')
  final String planType;
  @override
  @JsonKey(name: 'status')
  final String status;
  @override
  @JsonKey(name: 'trial_start_date')
  final DateTime? trialStartDate;
  @override
  @JsonKey(name: 'trial_end_date')
  final DateTime? trialEndDate;
  @override
  @JsonKey(name: 'subscription_start_date')
  final DateTime? subscriptionStartDate;
  @override
  @JsonKey(name: 'subscription_end_date')
  final DateTime? subscriptionEndDate;
  @override
  @JsonKey(name: 'auto_renew')
  final bool autoRenew;
  @override
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;
  @override
  @JsonKey(name: 'last_payment_date')
  final DateTime? lastPaymentDate;
  @override
  @JsonKey(name: 'next_payment_date')
  final DateTime? nextPaymentDate;
  @override
  @JsonKey(name: 'payment_amount')
  final double? paymentAmount;
  @override
  @JsonKey(name: 'currency')
  final String? currency;
  @override
  @JsonKey(name: 'child_profiles_limit')
  final int childProfilesLimit;
  final List<String> _features;
  @override
  @JsonKey(name: 'features')
  List<String> get features {
    if (_features is EqualUnmodifiableListView) return _features;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_features);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'SubscriptionStatus(id: $id, userId: $userId, planType: $planType, status: $status, trialStartDate: $trialStartDate, trialEndDate: $trialEndDate, subscriptionStartDate: $subscriptionStartDate, subscriptionEndDate: $subscriptionEndDate, autoRenew: $autoRenew, paymentMethod: $paymentMethod, lastPaymentDate: $lastPaymentDate, nextPaymentDate: $nextPaymentDate, paymentAmount: $paymentAmount, currency: $currency, childProfilesLimit: $childProfilesLimit, features: $features, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionStatusImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.planType, planType) ||
                other.planType == planType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.trialStartDate, trialStartDate) ||
                other.trialStartDate == trialStartDate) &&
            (identical(other.trialEndDate, trialEndDate) ||
                other.trialEndDate == trialEndDate) &&
            (identical(other.subscriptionStartDate, subscriptionStartDate) ||
                other.subscriptionStartDate == subscriptionStartDate) &&
            (identical(other.subscriptionEndDate, subscriptionEndDate) ||
                other.subscriptionEndDate == subscriptionEndDate) &&
            (identical(other.autoRenew, autoRenew) ||
                other.autoRenew == autoRenew) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.lastPaymentDate, lastPaymentDate) ||
                other.lastPaymentDate == lastPaymentDate) &&
            (identical(other.nextPaymentDate, nextPaymentDate) ||
                other.nextPaymentDate == nextPaymentDate) &&
            (identical(other.paymentAmount, paymentAmount) ||
                other.paymentAmount == paymentAmount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.childProfilesLimit, childProfilesLimit) ||
                other.childProfilesLimit == childProfilesLimit) &&
            const DeepCollectionEquality().equals(other._features, _features) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      planType,
      status,
      trialStartDate,
      trialEndDate,
      subscriptionStartDate,
      subscriptionEndDate,
      autoRenew,
      paymentMethod,
      lastPaymentDate,
      nextPaymentDate,
      paymentAmount,
      currency,
      childProfilesLimit,
      const DeepCollectionEquality().hash(_features),
      createdAt,
      updatedAt);

  /// Create a copy of SubscriptionStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionStatusImplCopyWith<_$SubscriptionStatusImpl> get copyWith =>
      __$$SubscriptionStatusImplCopyWithImpl<_$SubscriptionStatusImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscriptionStatusImplToJson(
      this,
    );
  }
}

abstract class _SubscriptionStatus extends SubscriptionStatus {
  const factory _SubscriptionStatus(
          {required final String id,
          required final String userId,
          @JsonKey(name: 'plan_type') required final String planType,
          @JsonKey(name: 'status') required final String status,
          @JsonKey(name: 'trial_start_date') final DateTime? trialStartDate,
          @JsonKey(name: 'trial_end_date') final DateTime? trialEndDate,
          @JsonKey(name: 'subscription_start_date')
          final DateTime? subscriptionStartDate,
          @JsonKey(name: 'subscription_end_date')
          final DateTime? subscriptionEndDate,
          @JsonKey(name: 'auto_renew') required final bool autoRenew,
          @JsonKey(name: 'payment_method') final String? paymentMethod,
          @JsonKey(name: 'last_payment_date') final DateTime? lastPaymentDate,
          @JsonKey(name: 'next_payment_date') final DateTime? nextPaymentDate,
          @JsonKey(name: 'payment_amount') final double? paymentAmount,
          @JsonKey(name: 'currency') final String? currency,
          @JsonKey(name: 'child_profiles_limit')
          required final int childProfilesLimit,
          @JsonKey(name: 'features') required final List<String> features,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'updated_at') required final DateTime updatedAt}) =
      _$SubscriptionStatusImpl;
  const _SubscriptionStatus._() : super._();

  factory _SubscriptionStatus.fromJson(Map<String, dynamic> json) =
      _$SubscriptionStatusImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  @JsonKey(name: 'plan_type')
  String get planType;
  @override
  @JsonKey(name: 'status')
  String get status;
  @override
  @JsonKey(name: 'trial_start_date')
  DateTime? get trialStartDate;
  @override
  @JsonKey(name: 'trial_end_date')
  DateTime? get trialEndDate;
  @override
  @JsonKey(name: 'subscription_start_date')
  DateTime? get subscriptionStartDate;
  @override
  @JsonKey(name: 'subscription_end_date')
  DateTime? get subscriptionEndDate;
  @override
  @JsonKey(name: 'auto_renew')
  bool get autoRenew;
  @override
  @JsonKey(name: 'payment_method')
  String? get paymentMethod;
  @override
  @JsonKey(name: 'last_payment_date')
  DateTime? get lastPaymentDate;
  @override
  @JsonKey(name: 'next_payment_date')
  DateTime? get nextPaymentDate;
  @override
  @JsonKey(name: 'payment_amount')
  double? get paymentAmount;
  @override
  @JsonKey(name: 'currency')
  String? get currency;
  @override
  @JsonKey(name: 'child_profiles_limit')
  int get childProfilesLimit;
  @override
  @JsonKey(name: 'features')
  List<String> get features;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of SubscriptionStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionStatusImplCopyWith<_$SubscriptionStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
