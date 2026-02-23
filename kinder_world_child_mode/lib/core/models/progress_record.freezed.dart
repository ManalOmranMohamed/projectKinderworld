// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progress_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProgressRecord _$ProgressRecordFromJson(Map<String, dynamic> json) {
  return _ProgressRecord.fromJson(json);
}

/// @nodoc
mixin _$ProgressRecord {
  String get id => throw _privateConstructorUsedError;
  String get childId => throw _privateConstructorUsedError;
  String get activityId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  int get duration => throw _privateConstructorUsedError;
  int get xpEarned => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  @JsonKey(name: 'completion_status')
  String get completionStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'performance_metrics')
  Map<String, dynamic>? get performanceMetrics =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'ai_feedback')
  String? get aiFeedback => throw _privateConstructorUsedError;
  @JsonKey(name: 'mood_before')
  String? get moodBefore => throw _privateConstructorUsedError;
  @JsonKey(name: 'mood_after')
  String? get moodAfter => throw _privateConstructorUsedError;
  @JsonKey(name: 'difficulty_adjusted')
  bool? get difficultyAdjusted => throw _privateConstructorUsedError;
  @JsonKey(name: 'help_requested')
  bool? get helpRequested => throw _privateConstructorUsedError;
  @JsonKey(name: 'parent_approved')
  bool? get parentApproved => throw _privateConstructorUsedError;
  @JsonKey(name: 'sync_status')
  String get syncStatus => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ProgressRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProgressRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProgressRecordCopyWith<ProgressRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressRecordCopyWith<$Res> {
  factory $ProgressRecordCopyWith(
          ProgressRecord value, $Res Function(ProgressRecord) then) =
      _$ProgressRecordCopyWithImpl<$Res, ProgressRecord>;
  @useResult
  $Res call(
      {String id,
      String childId,
      String activityId,
      DateTime date,
      int score,
      int duration,
      int xpEarned,
      String? notes,
      @JsonKey(name: 'completion_status') String completionStatus,
      @JsonKey(name: 'performance_metrics')
      Map<String, dynamic>? performanceMetrics,
      @JsonKey(name: 'ai_feedback') String? aiFeedback,
      @JsonKey(name: 'mood_before') String? moodBefore,
      @JsonKey(name: 'mood_after') String? moodAfter,
      @JsonKey(name: 'difficulty_adjusted') bool? difficultyAdjusted,
      @JsonKey(name: 'help_requested') bool? helpRequested,
      @JsonKey(name: 'parent_approved') bool? parentApproved,
      @JsonKey(name: 'sync_status') String syncStatus,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class _$ProgressRecordCopyWithImpl<$Res, $Val extends ProgressRecord>
    implements $ProgressRecordCopyWith<$Res> {
  _$ProgressRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProgressRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? childId = null,
    Object? activityId = null,
    Object? date = null,
    Object? score = null,
    Object? duration = null,
    Object? xpEarned = null,
    Object? notes = freezed,
    Object? completionStatus = null,
    Object? performanceMetrics = freezed,
    Object? aiFeedback = freezed,
    Object? moodBefore = freezed,
    Object? moodAfter = freezed,
    Object? difficultyAdjusted = freezed,
    Object? helpRequested = freezed,
    Object? parentApproved = freezed,
    Object? syncStatus = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      childId: null == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String,
      activityId: null == activityId
          ? _value.activityId
          : activityId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      xpEarned: null == xpEarned
          ? _value.xpEarned
          : xpEarned // ignore: cast_nullable_to_non_nullable
              as int,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      completionStatus: null == completionStatus
          ? _value.completionStatus
          : completionStatus // ignore: cast_nullable_to_non_nullable
              as String,
      performanceMetrics: freezed == performanceMetrics
          ? _value.performanceMetrics
          : performanceMetrics // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      aiFeedback: freezed == aiFeedback
          ? _value.aiFeedback
          : aiFeedback // ignore: cast_nullable_to_non_nullable
              as String?,
      moodBefore: freezed == moodBefore
          ? _value.moodBefore
          : moodBefore // ignore: cast_nullable_to_non_nullable
              as String?,
      moodAfter: freezed == moodAfter
          ? _value.moodAfter
          : moodAfter // ignore: cast_nullable_to_non_nullable
              as String?,
      difficultyAdjusted: freezed == difficultyAdjusted
          ? _value.difficultyAdjusted
          : difficultyAdjusted // ignore: cast_nullable_to_non_nullable
              as bool?,
      helpRequested: freezed == helpRequested
          ? _value.helpRequested
          : helpRequested // ignore: cast_nullable_to_non_nullable
              as bool?,
      parentApproved: freezed == parentApproved
          ? _value.parentApproved
          : parentApproved // ignore: cast_nullable_to_non_nullable
              as bool?,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as String,
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
abstract class _$$ProgressRecordImplCopyWith<$Res>
    implements $ProgressRecordCopyWith<$Res> {
  factory _$$ProgressRecordImplCopyWith(_$ProgressRecordImpl value,
          $Res Function(_$ProgressRecordImpl) then) =
      __$$ProgressRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String childId,
      String activityId,
      DateTime date,
      int score,
      int duration,
      int xpEarned,
      String? notes,
      @JsonKey(name: 'completion_status') String completionStatus,
      @JsonKey(name: 'performance_metrics')
      Map<String, dynamic>? performanceMetrics,
      @JsonKey(name: 'ai_feedback') String? aiFeedback,
      @JsonKey(name: 'mood_before') String? moodBefore,
      @JsonKey(name: 'mood_after') String? moodAfter,
      @JsonKey(name: 'difficulty_adjusted') bool? difficultyAdjusted,
      @JsonKey(name: 'help_requested') bool? helpRequested,
      @JsonKey(name: 'parent_approved') bool? parentApproved,
      @JsonKey(name: 'sync_status') String syncStatus,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class __$$ProgressRecordImplCopyWithImpl<$Res>
    extends _$ProgressRecordCopyWithImpl<$Res, _$ProgressRecordImpl>
    implements _$$ProgressRecordImplCopyWith<$Res> {
  __$$ProgressRecordImplCopyWithImpl(
      _$ProgressRecordImpl _value, $Res Function(_$ProgressRecordImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProgressRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? childId = null,
    Object? activityId = null,
    Object? date = null,
    Object? score = null,
    Object? duration = null,
    Object? xpEarned = null,
    Object? notes = freezed,
    Object? completionStatus = null,
    Object? performanceMetrics = freezed,
    Object? aiFeedback = freezed,
    Object? moodBefore = freezed,
    Object? moodAfter = freezed,
    Object? difficultyAdjusted = freezed,
    Object? helpRequested = freezed,
    Object? parentApproved = freezed,
    Object? syncStatus = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$ProgressRecordImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      childId: null == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String,
      activityId: null == activityId
          ? _value.activityId
          : activityId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      xpEarned: null == xpEarned
          ? _value.xpEarned
          : xpEarned // ignore: cast_nullable_to_non_nullable
              as int,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      completionStatus: null == completionStatus
          ? _value.completionStatus
          : completionStatus // ignore: cast_nullable_to_non_nullable
              as String,
      performanceMetrics: freezed == performanceMetrics
          ? _value._performanceMetrics
          : performanceMetrics // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      aiFeedback: freezed == aiFeedback
          ? _value.aiFeedback
          : aiFeedback // ignore: cast_nullable_to_non_nullable
              as String?,
      moodBefore: freezed == moodBefore
          ? _value.moodBefore
          : moodBefore // ignore: cast_nullable_to_non_nullable
              as String?,
      moodAfter: freezed == moodAfter
          ? _value.moodAfter
          : moodAfter // ignore: cast_nullable_to_non_nullable
              as String?,
      difficultyAdjusted: freezed == difficultyAdjusted
          ? _value.difficultyAdjusted
          : difficultyAdjusted // ignore: cast_nullable_to_non_nullable
              as bool?,
      helpRequested: freezed == helpRequested
          ? _value.helpRequested
          : helpRequested // ignore: cast_nullable_to_non_nullable
              as bool?,
      parentApproved: freezed == parentApproved
          ? _value.parentApproved
          : parentApproved // ignore: cast_nullable_to_non_nullable
              as bool?,
      syncStatus: null == syncStatus
          ? _value.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as String,
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
class _$ProgressRecordImpl extends _ProgressRecord {
  const _$ProgressRecordImpl(
      {required this.id,
      required this.childId,
      required this.activityId,
      required this.date,
      required this.score,
      required this.duration,
      required this.xpEarned,
      this.notes,
      @JsonKey(name: 'completion_status') required this.completionStatus,
      @JsonKey(name: 'performance_metrics')
      final Map<String, dynamic>? performanceMetrics,
      @JsonKey(name: 'ai_feedback') this.aiFeedback,
      @JsonKey(name: 'mood_before') this.moodBefore,
      @JsonKey(name: 'mood_after') this.moodAfter,
      @JsonKey(name: 'difficulty_adjusted') this.difficultyAdjusted,
      @JsonKey(name: 'help_requested') this.helpRequested,
      @JsonKey(name: 'parent_approved') this.parentApproved,
      @JsonKey(name: 'sync_status') required this.syncStatus,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt})
      : _performanceMetrics = performanceMetrics,
        super._();

  factory _$ProgressRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgressRecordImplFromJson(json);

  @override
  final String id;
  @override
  final String childId;
  @override
  final String activityId;
  @override
  final DateTime date;
  @override
  final int score;
  @override
  final int duration;
  @override
  final int xpEarned;
  @override
  final String? notes;
  @override
  @JsonKey(name: 'completion_status')
  final String completionStatus;
  final Map<String, dynamic>? _performanceMetrics;
  @override
  @JsonKey(name: 'performance_metrics')
  Map<String, dynamic>? get performanceMetrics {
    final value = _performanceMetrics;
    if (value == null) return null;
    if (_performanceMetrics is EqualUnmodifiableMapView)
      return _performanceMetrics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'ai_feedback')
  final String? aiFeedback;
  @override
  @JsonKey(name: 'mood_before')
  final String? moodBefore;
  @override
  @JsonKey(name: 'mood_after')
  final String? moodAfter;
  @override
  @JsonKey(name: 'difficulty_adjusted')
  final bool? difficultyAdjusted;
  @override
  @JsonKey(name: 'help_requested')
  final bool? helpRequested;
  @override
  @JsonKey(name: 'parent_approved')
  final bool? parentApproved;
  @override
  @JsonKey(name: 'sync_status')
  final String syncStatus;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'ProgressRecord(id: $id, childId: $childId, activityId: $activityId, date: $date, score: $score, duration: $duration, xpEarned: $xpEarned, notes: $notes, completionStatus: $completionStatus, performanceMetrics: $performanceMetrics, aiFeedback: $aiFeedback, moodBefore: $moodBefore, moodAfter: $moodAfter, difficultyAdjusted: $difficultyAdjusted, helpRequested: $helpRequested, parentApproved: $parentApproved, syncStatus: $syncStatus, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.activityId, activityId) ||
                other.activityId == activityId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.xpEarned, xpEarned) ||
                other.xpEarned == xpEarned) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.completionStatus, completionStatus) ||
                other.completionStatus == completionStatus) &&
            const DeepCollectionEquality()
                .equals(other._performanceMetrics, _performanceMetrics) &&
            (identical(other.aiFeedback, aiFeedback) ||
                other.aiFeedback == aiFeedback) &&
            (identical(other.moodBefore, moodBefore) ||
                other.moodBefore == moodBefore) &&
            (identical(other.moodAfter, moodAfter) ||
                other.moodAfter == moodAfter) &&
            (identical(other.difficultyAdjusted, difficultyAdjusted) ||
                other.difficultyAdjusted == difficultyAdjusted) &&
            (identical(other.helpRequested, helpRequested) ||
                other.helpRequested == helpRequested) &&
            (identical(other.parentApproved, parentApproved) ||
                other.parentApproved == parentApproved) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        childId,
        activityId,
        date,
        score,
        duration,
        xpEarned,
        notes,
        completionStatus,
        const DeepCollectionEquality().hash(_performanceMetrics),
        aiFeedback,
        moodBefore,
        moodAfter,
        difficultyAdjusted,
        helpRequested,
        parentApproved,
        syncStatus,
        createdAt,
        updatedAt
      ]);

  /// Create a copy of ProgressRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressRecordImplCopyWith<_$ProgressRecordImpl> get copyWith =>
      __$$ProgressRecordImplCopyWithImpl<_$ProgressRecordImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgressRecordImplToJson(
      this,
    );
  }
}

abstract class _ProgressRecord extends ProgressRecord {
  const factory _ProgressRecord(
          {required final String id,
          required final String childId,
          required final String activityId,
          required final DateTime date,
          required final int score,
          required final int duration,
          required final int xpEarned,
          final String? notes,
          @JsonKey(name: 'completion_status')
          required final String completionStatus,
          @JsonKey(name: 'performance_metrics')
          final Map<String, dynamic>? performanceMetrics,
          @JsonKey(name: 'ai_feedback') final String? aiFeedback,
          @JsonKey(name: 'mood_before') final String? moodBefore,
          @JsonKey(name: 'mood_after') final String? moodAfter,
          @JsonKey(name: 'difficulty_adjusted') final bool? difficultyAdjusted,
          @JsonKey(name: 'help_requested') final bool? helpRequested,
          @JsonKey(name: 'parent_approved') final bool? parentApproved,
          @JsonKey(name: 'sync_status') required final String syncStatus,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'updated_at') required final DateTime updatedAt}) =
      _$ProgressRecordImpl;
  const _ProgressRecord._() : super._();

  factory _ProgressRecord.fromJson(Map<String, dynamic> json) =
      _$ProgressRecordImpl.fromJson;

  @override
  String get id;
  @override
  String get childId;
  @override
  String get activityId;
  @override
  DateTime get date;
  @override
  int get score;
  @override
  int get duration;
  @override
  int get xpEarned;
  @override
  String? get notes;
  @override
  @JsonKey(name: 'completion_status')
  String get completionStatus;
  @override
  @JsonKey(name: 'performance_metrics')
  Map<String, dynamic>? get performanceMetrics;
  @override
  @JsonKey(name: 'ai_feedback')
  String? get aiFeedback;
  @override
  @JsonKey(name: 'mood_before')
  String? get moodBefore;
  @override
  @JsonKey(name: 'mood_after')
  String? get moodAfter;
  @override
  @JsonKey(name: 'difficulty_adjusted')
  bool? get difficultyAdjusted;
  @override
  @JsonKey(name: 'help_requested')
  bool? get helpRequested;
  @override
  @JsonKey(name: 'parent_approved')
  bool? get parentApproved;
  @override
  @JsonKey(name: 'sync_status')
  String get syncStatus;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of ProgressRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgressRecordImplCopyWith<_$ProgressRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
