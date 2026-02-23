// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Activity _$ActivityFromJson(Map<String, dynamic> json) {
  return _Activity.fromJson(json);
}

/// @nodoc
mixin _$Activity {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get aspect => throw _privateConstructorUsedError;
  List<String> get ageRange => throw _privateConstructorUsedError;
  String get difficulty => throw _privateConstructorUsedError;
  int get duration => throw _privateConstructorUsedError;
  int get xpReward => throw _privateConstructorUsedError;
  String get thumbnailUrl => throw _privateConstructorUsedError;
  String? get contentUrl => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  List<String> get learningObjectives => throw _privateConstructorUsedError;
  String? get instructions => throw _privateConstructorUsedError;
  List<String>? get materialsNeeded => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_offline_available')
  bool get isOfflineAvailable => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_premium')
  bool get isPremium => throw _privateConstructorUsedError;
  @JsonKey(name: 'parent_approval_required')
  bool get parentApprovalRequired => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'completion_rate')
  double? get completionRate => throw _privateConstructorUsedError;
  @JsonKey(name: 'average_rating')
  double? get averageRating => throw _privateConstructorUsedError;
  @JsonKey(name: 'play_count')
  int get playCount => throw _privateConstructorUsedError;

  /// Serializes this Activity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivityCopyWith<Activity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityCopyWith<$Res> {
  factory $ActivityCopyWith(Activity value, $Res Function(Activity) then) =
      _$ActivityCopyWithImpl<$Res, Activity>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String category,
      String type,
      String aspect,
      List<String> ageRange,
      String difficulty,
      int duration,
      int xpReward,
      String thumbnailUrl,
      String? contentUrl,
      List<String> tags,
      List<String> learningObjectives,
      String? instructions,
      List<String>? materialsNeeded,
      @JsonKey(name: 'is_offline_available') bool isOfflineAvailable,
      @JsonKey(name: 'is_premium') bool isPremium,
      @JsonKey(name: 'parent_approval_required') bool parentApprovalRequired,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'completion_rate') double? completionRate,
      @JsonKey(name: 'average_rating') double? averageRating,
      @JsonKey(name: 'play_count') int playCount});
}

/// @nodoc
class _$ActivityCopyWithImpl<$Res, $Val extends Activity>
    implements $ActivityCopyWith<$Res> {
  _$ActivityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? category = null,
    Object? type = null,
    Object? aspect = null,
    Object? ageRange = null,
    Object? difficulty = null,
    Object? duration = null,
    Object? xpReward = null,
    Object? thumbnailUrl = null,
    Object? contentUrl = freezed,
    Object? tags = null,
    Object? learningObjectives = null,
    Object? instructions = freezed,
    Object? materialsNeeded = freezed,
    Object? isOfflineAvailable = null,
    Object? isPremium = null,
    Object? parentApprovalRequired = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? completionRate = freezed,
    Object? averageRating = freezed,
    Object? playCount = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      aspect: null == aspect
          ? _value.aspect
          : aspect // ignore: cast_nullable_to_non_nullable
              as String,
      ageRange: null == ageRange
          ? _value.ageRange
          : ageRange // ignore: cast_nullable_to_non_nullable
              as List<String>,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      xpReward: null == xpReward
          ? _value.xpReward
          : xpReward // ignore: cast_nullable_to_non_nullable
              as int,
      thumbnailUrl: null == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String,
      contentUrl: freezed == contentUrl
          ? _value.contentUrl
          : contentUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      learningObjectives: null == learningObjectives
          ? _value.learningObjectives
          : learningObjectives // ignore: cast_nullable_to_non_nullable
              as List<String>,
      instructions: freezed == instructions
          ? _value.instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as String?,
      materialsNeeded: freezed == materialsNeeded
          ? _value.materialsNeeded
          : materialsNeeded // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      isOfflineAvailable: null == isOfflineAvailable
          ? _value.isOfflineAvailable
          : isOfflineAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      isPremium: null == isPremium
          ? _value.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      parentApprovalRequired: null == parentApprovalRequired
          ? _value.parentApprovalRequired
          : parentApprovalRequired // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completionRate: freezed == completionRate
          ? _value.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double?,
      averageRating: freezed == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double?,
      playCount: null == playCount
          ? _value.playCount
          : playCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ActivityImplCopyWith<$Res>
    implements $ActivityCopyWith<$Res> {
  factory _$$ActivityImplCopyWith(
          _$ActivityImpl value, $Res Function(_$ActivityImpl) then) =
      __$$ActivityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String category,
      String type,
      String aspect,
      List<String> ageRange,
      String difficulty,
      int duration,
      int xpReward,
      String thumbnailUrl,
      String? contentUrl,
      List<String> tags,
      List<String> learningObjectives,
      String? instructions,
      List<String>? materialsNeeded,
      @JsonKey(name: 'is_offline_available') bool isOfflineAvailable,
      @JsonKey(name: 'is_premium') bool isPremium,
      @JsonKey(name: 'parent_approval_required') bool parentApprovalRequired,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(name: 'completion_rate') double? completionRate,
      @JsonKey(name: 'average_rating') double? averageRating,
      @JsonKey(name: 'play_count') int playCount});
}

/// @nodoc
class __$$ActivityImplCopyWithImpl<$Res>
    extends _$ActivityCopyWithImpl<$Res, _$ActivityImpl>
    implements _$$ActivityImplCopyWith<$Res> {
  __$$ActivityImplCopyWithImpl(
      _$ActivityImpl _value, $Res Function(_$ActivityImpl) _then)
      : super(_value, _then);

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? category = null,
    Object? type = null,
    Object? aspect = null,
    Object? ageRange = null,
    Object? difficulty = null,
    Object? duration = null,
    Object? xpReward = null,
    Object? thumbnailUrl = null,
    Object? contentUrl = freezed,
    Object? tags = null,
    Object? learningObjectives = null,
    Object? instructions = freezed,
    Object? materialsNeeded = freezed,
    Object? isOfflineAvailable = null,
    Object? isPremium = null,
    Object? parentApprovalRequired = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? completionRate = freezed,
    Object? averageRating = freezed,
    Object? playCount = null,
  }) {
    return _then(_$ActivityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      aspect: null == aspect
          ? _value.aspect
          : aspect // ignore: cast_nullable_to_non_nullable
              as String,
      ageRange: null == ageRange
          ? _value._ageRange
          : ageRange // ignore: cast_nullable_to_non_nullable
              as List<String>,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      xpReward: null == xpReward
          ? _value.xpReward
          : xpReward // ignore: cast_nullable_to_non_nullable
              as int,
      thumbnailUrl: null == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String,
      contentUrl: freezed == contentUrl
          ? _value.contentUrl
          : contentUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      learningObjectives: null == learningObjectives
          ? _value._learningObjectives
          : learningObjectives // ignore: cast_nullable_to_non_nullable
              as List<String>,
      instructions: freezed == instructions
          ? _value.instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as String?,
      materialsNeeded: freezed == materialsNeeded
          ? _value._materialsNeeded
          : materialsNeeded // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      isOfflineAvailable: null == isOfflineAvailable
          ? _value.isOfflineAvailable
          : isOfflineAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      isPremium: null == isPremium
          ? _value.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      parentApprovalRequired: null == parentApprovalRequired
          ? _value.parentApprovalRequired
          : parentApprovalRequired // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completionRate: freezed == completionRate
          ? _value.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double?,
      averageRating: freezed == averageRating
          ? _value.averageRating
          : averageRating // ignore: cast_nullable_to_non_nullable
              as double?,
      playCount: null == playCount
          ? _value.playCount
          : playCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ActivityImpl extends _Activity {
  const _$ActivityImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.category,
      required this.type,
      required this.aspect,
      required final List<String> ageRange,
      required this.difficulty,
      required this.duration,
      required this.xpReward,
      required this.thumbnailUrl,
      this.contentUrl,
      required final List<String> tags,
      required final List<String> learningObjectives,
      this.instructions,
      final List<String>? materialsNeeded,
      @JsonKey(name: 'is_offline_available') required this.isOfflineAvailable,
      @JsonKey(name: 'is_premium') required this.isPremium,
      @JsonKey(name: 'parent_approval_required')
      required this.parentApprovalRequired,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt,
      @JsonKey(name: 'completion_rate') this.completionRate,
      @JsonKey(name: 'average_rating') this.averageRating,
      @JsonKey(name: 'play_count') required this.playCount})
      : _ageRange = ageRange,
        _tags = tags,
        _learningObjectives = learningObjectives,
        _materialsNeeded = materialsNeeded,
        super._();

  factory _$ActivityImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivityImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String category;
  @override
  final String type;
  @override
  final String aspect;
  final List<String> _ageRange;
  @override
  List<String> get ageRange {
    if (_ageRange is EqualUnmodifiableListView) return _ageRange;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ageRange);
  }

  @override
  final String difficulty;
  @override
  final int duration;
  @override
  final int xpReward;
  @override
  final String thumbnailUrl;
  @override
  final String? contentUrl;
  final List<String> _tags;
  @override
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  final List<String> _learningObjectives;
  @override
  List<String> get learningObjectives {
    if (_learningObjectives is EqualUnmodifiableListView)
      return _learningObjectives;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_learningObjectives);
  }

  @override
  final String? instructions;
  final List<String>? _materialsNeeded;
  @override
  List<String>? get materialsNeeded {
    final value = _materialsNeeded;
    if (value == null) return null;
    if (_materialsNeeded is EqualUnmodifiableListView) return _materialsNeeded;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: 'is_offline_available')
  final bool isOfflineAvailable;
  @override
  @JsonKey(name: 'is_premium')
  final bool isPremium;
  @override
  @JsonKey(name: 'parent_approval_required')
  final bool parentApprovalRequired;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @override
  @JsonKey(name: 'completion_rate')
  final double? completionRate;
  @override
  @JsonKey(name: 'average_rating')
  final double? averageRating;
  @override
  @JsonKey(name: 'play_count')
  final int playCount;

  @override
  String toString() {
    return 'Activity(id: $id, title: $title, description: $description, category: $category, type: $type, aspect: $aspect, ageRange: $ageRange, difficulty: $difficulty, duration: $duration, xpReward: $xpReward, thumbnailUrl: $thumbnailUrl, contentUrl: $contentUrl, tags: $tags, learningObjectives: $learningObjectives, instructions: $instructions, materialsNeeded: $materialsNeeded, isOfflineAvailable: $isOfflineAvailable, isPremium: $isPremium, parentApprovalRequired: $parentApprovalRequired, createdAt: $createdAt, updatedAt: $updatedAt, completionRate: $completionRate, averageRating: $averageRating, playCount: $playCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.aspect, aspect) || other.aspect == aspect) &&
            const DeepCollectionEquality().equals(other._ageRange, _ageRange) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.xpReward, xpReward) ||
                other.xpReward == xpReward) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.contentUrl, contentUrl) ||
                other.contentUrl == contentUrl) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality()
                .equals(other._learningObjectives, _learningObjectives) &&
            (identical(other.instructions, instructions) ||
                other.instructions == instructions) &&
            const DeepCollectionEquality()
                .equals(other._materialsNeeded, _materialsNeeded) &&
            (identical(other.isOfflineAvailable, isOfflineAvailable) ||
                other.isOfflineAvailable == isOfflineAvailable) &&
            (identical(other.isPremium, isPremium) ||
                other.isPremium == isPremium) &&
            (identical(other.parentApprovalRequired, parentApprovalRequired) ||
                other.parentApprovalRequired == parentApprovalRequired) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.completionRate, completionRate) ||
                other.completionRate == completionRate) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            (identical(other.playCount, playCount) ||
                other.playCount == playCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        description,
        category,
        type,
        aspect,
        const DeepCollectionEquality().hash(_ageRange),
        difficulty,
        duration,
        xpReward,
        thumbnailUrl,
        contentUrl,
        const DeepCollectionEquality().hash(_tags),
        const DeepCollectionEquality().hash(_learningObjectives),
        instructions,
        const DeepCollectionEquality().hash(_materialsNeeded),
        isOfflineAvailable,
        isPremium,
        parentApprovalRequired,
        createdAt,
        updatedAt,
        completionRate,
        averageRating,
        playCount
      ]);

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivityImplCopyWith<_$ActivityImpl> get copyWith =>
      __$$ActivityImplCopyWithImpl<_$ActivityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivityImplToJson(
      this,
    );
  }
}

abstract class _Activity extends Activity {
  const factory _Activity(
          {required final String id,
          required final String title,
          required final String description,
          required final String category,
          required final String type,
          required final String aspect,
          required final List<String> ageRange,
          required final String difficulty,
          required final int duration,
          required final int xpReward,
          required final String thumbnailUrl,
          final String? contentUrl,
          required final List<String> tags,
          required final List<String> learningObjectives,
          final String? instructions,
          final List<String>? materialsNeeded,
          @JsonKey(name: 'is_offline_available')
          required final bool isOfflineAvailable,
          @JsonKey(name: 'is_premium') required final bool isPremium,
          @JsonKey(name: 'parent_approval_required')
          required final bool parentApprovalRequired,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'updated_at') required final DateTime updatedAt,
          @JsonKey(name: 'completion_rate') final double? completionRate,
          @JsonKey(name: 'average_rating') final double? averageRating,
          @JsonKey(name: 'play_count') required final int playCount}) =
      _$ActivityImpl;
  const _Activity._() : super._();

  factory _Activity.fromJson(Map<String, dynamic> json) =
      _$ActivityImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get category;
  @override
  String get type;
  @override
  String get aspect;
  @override
  List<String> get ageRange;
  @override
  String get difficulty;
  @override
  int get duration;
  @override
  int get xpReward;
  @override
  String get thumbnailUrl;
  @override
  String? get contentUrl;
  @override
  List<String> get tags;
  @override
  List<String> get learningObjectives;
  @override
  String? get instructions;
  @override
  List<String>? get materialsNeeded;
  @override
  @JsonKey(name: 'is_offline_available')
  bool get isOfflineAvailable;
  @override
  @JsonKey(name: 'is_premium')
  bool get isPremium;
  @override
  @JsonKey(name: 'parent_approval_required')
  bool get parentApprovalRequired;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override
  @JsonKey(name: 'completion_rate')
  double? get completionRate;
  @override
  @JsonKey(name: 'average_rating')
  double? get averageRating;
  @override
  @JsonKey(name: 'play_count')
  int get playCount;

  /// Create a copy of Activity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivityImplCopyWith<_$ActivityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
