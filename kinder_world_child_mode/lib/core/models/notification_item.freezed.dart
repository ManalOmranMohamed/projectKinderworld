// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NotificationItem _$NotificationItemFromJson(Map<String, dynamic> json) {
  return _NotificationItem.fromJson(json);
}

/// @nodoc
mixin _$NotificationItem {
  String get id => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  String get recipientId => throw _privateConstructorUsedError;
  String get recipientRole => throw _privateConstructorUsedError;
  @JsonKey(name: 'related_child_id')
  String? get relatedChildId => throw _privateConstructorUsedError;
  @JsonKey(name: 'related_activity_id')
  String? get relatedActivityId => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_read')
  bool get isRead => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_sent')
  bool get isSent => throw _privateConstructorUsedError;
  @JsonKey(name: 'sent_at')
  DateTime? get sentAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'read_at')
  DateTime? get readAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'priority')
  String get priority => throw _privateConstructorUsedError;
  Map<String, dynamic>? get data => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'expires_at')
  DateTime? get expiresAt => throw _privateConstructorUsedError;

  /// Serializes this NotificationItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationItemCopyWith<NotificationItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationItemCopyWith<$Res> {
  factory $NotificationItemCopyWith(
          NotificationItem value, $Res Function(NotificationItem) then) =
      _$NotificationItemCopyWithImpl<$Res, NotificationItem>;
  @useResult
  $Res call(
      {String id,
      String type,
      String title,
      String body,
      String recipientId,
      String recipientRole,
      @JsonKey(name: 'related_child_id') String? relatedChildId,
      @JsonKey(name: 'related_activity_id') String? relatedActivityId,
      @JsonKey(name: 'is_read') bool isRead,
      @JsonKey(name: 'is_sent') bool isSent,
      @JsonKey(name: 'sent_at') DateTime? sentAt,
      @JsonKey(name: 'read_at') DateTime? readAt,
      @JsonKey(name: 'priority') String priority,
      Map<String, dynamic>? data,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'expires_at') DateTime? expiresAt});
}

/// @nodoc
class _$NotificationItemCopyWithImpl<$Res, $Val extends NotificationItem>
    implements $NotificationItemCopyWith<$Res> {
  _$NotificationItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? body = null,
    Object? recipientId = null,
    Object? recipientRole = null,
    Object? relatedChildId = freezed,
    Object? relatedActivityId = freezed,
    Object? isRead = null,
    Object? isSent = null,
    Object? sentAt = freezed,
    Object? readAt = freezed,
    Object? priority = null,
    Object? data = freezed,
    Object? createdAt = null,
    Object? expiresAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      recipientId: null == recipientId
          ? _value.recipientId
          : recipientId // ignore: cast_nullable_to_non_nullable
              as String,
      recipientRole: null == recipientRole
          ? _value.recipientRole
          : recipientRole // ignore: cast_nullable_to_non_nullable
              as String,
      relatedChildId: freezed == relatedChildId
          ? _value.relatedChildId
          : relatedChildId // ignore: cast_nullable_to_non_nullable
              as String?,
      relatedActivityId: freezed == relatedActivityId
          ? _value.relatedActivityId
          : relatedActivityId // ignore: cast_nullable_to_non_nullable
              as String?,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      isSent: null == isSent
          ? _value.isSent
          : isSent // ignore: cast_nullable_to_non_nullable
              as bool,
      sentAt: freezed == sentAt
          ? _value.sentAt
          : sentAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      readAt: freezed == readAt
          ? _value.readAt
          : readAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationItemImplCopyWith<$Res>
    implements $NotificationItemCopyWith<$Res> {
  factory _$$NotificationItemImplCopyWith(_$NotificationItemImpl value,
          $Res Function(_$NotificationItemImpl) then) =
      __$$NotificationItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String type,
      String title,
      String body,
      String recipientId,
      String recipientRole,
      @JsonKey(name: 'related_child_id') String? relatedChildId,
      @JsonKey(name: 'related_activity_id') String? relatedActivityId,
      @JsonKey(name: 'is_read') bool isRead,
      @JsonKey(name: 'is_sent') bool isSent,
      @JsonKey(name: 'sent_at') DateTime? sentAt,
      @JsonKey(name: 'read_at') DateTime? readAt,
      @JsonKey(name: 'priority') String priority,
      Map<String, dynamic>? data,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'expires_at') DateTime? expiresAt});
}

/// @nodoc
class __$$NotificationItemImplCopyWithImpl<$Res>
    extends _$NotificationItemCopyWithImpl<$Res, _$NotificationItemImpl>
    implements _$$NotificationItemImplCopyWith<$Res> {
  __$$NotificationItemImplCopyWithImpl(_$NotificationItemImpl _value,
      $Res Function(_$NotificationItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? title = null,
    Object? body = null,
    Object? recipientId = null,
    Object? recipientRole = null,
    Object? relatedChildId = freezed,
    Object? relatedActivityId = freezed,
    Object? isRead = null,
    Object? isSent = null,
    Object? sentAt = freezed,
    Object? readAt = freezed,
    Object? priority = null,
    Object? data = freezed,
    Object? createdAt = null,
    Object? expiresAt = freezed,
  }) {
    return _then(_$NotificationItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      recipientId: null == recipientId
          ? _value.recipientId
          : recipientId // ignore: cast_nullable_to_non_nullable
              as String,
      recipientRole: null == recipientRole
          ? _value.recipientRole
          : recipientRole // ignore: cast_nullable_to_non_nullable
              as String,
      relatedChildId: freezed == relatedChildId
          ? _value.relatedChildId
          : relatedChildId // ignore: cast_nullable_to_non_nullable
              as String?,
      relatedActivityId: freezed == relatedActivityId
          ? _value.relatedActivityId
          : relatedActivityId // ignore: cast_nullable_to_non_nullable
              as String?,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      isSent: null == isSent
          ? _value.isSent
          : isSent // ignore: cast_nullable_to_non_nullable
              as bool,
      sentAt: freezed == sentAt
          ? _value.sentAt
          : sentAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      readAt: freezed == readAt
          ? _value.readAt
          : readAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String,
      data: freezed == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationItemImpl extends _NotificationItem {
  const _$NotificationItemImpl(
      {required this.id,
      required this.type,
      required this.title,
      required this.body,
      required this.recipientId,
      required this.recipientRole,
      @JsonKey(name: 'related_child_id') this.relatedChildId,
      @JsonKey(name: 'related_activity_id') this.relatedActivityId,
      @JsonKey(name: 'is_read') required this.isRead,
      @JsonKey(name: 'is_sent') required this.isSent,
      @JsonKey(name: 'sent_at') this.sentAt,
      @JsonKey(name: 'read_at') this.readAt,
      @JsonKey(name: 'priority') required this.priority,
      final Map<String, dynamic>? data,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'expires_at') this.expiresAt})
      : _data = data,
        super._();

  factory _$NotificationItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationItemImplFromJson(json);

  @override
  final String id;
  @override
  final String type;
  @override
  final String title;
  @override
  final String body;
  @override
  final String recipientId;
  @override
  final String recipientRole;
  @override
  @JsonKey(name: 'related_child_id')
  final String? relatedChildId;
  @override
  @JsonKey(name: 'related_activity_id')
  final String? relatedActivityId;
  @override
  @JsonKey(name: 'is_read')
  final bool isRead;
  @override
  @JsonKey(name: 'is_sent')
  final bool isSent;
  @override
  @JsonKey(name: 'sent_at')
  final DateTime? sentAt;
  @override
  @JsonKey(name: 'read_at')
  final DateTime? readAt;
  @override
  @JsonKey(name: 'priority')
  final String priority;
  final Map<String, dynamic>? _data;
  @override
  Map<String, dynamic>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;

  @override
  String toString() {
    return 'NotificationItem(id: $id, type: $type, title: $title, body: $body, recipientId: $recipientId, recipientRole: $recipientRole, relatedChildId: $relatedChildId, relatedActivityId: $relatedActivityId, isRead: $isRead, isSent: $isSent, sentAt: $sentAt, readAt: $readAt, priority: $priority, data: $data, createdAt: $createdAt, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.recipientId, recipientId) ||
                other.recipientId == recipientId) &&
            (identical(other.recipientRole, recipientRole) ||
                other.recipientRole == recipientRole) &&
            (identical(other.relatedChildId, relatedChildId) ||
                other.relatedChildId == relatedChildId) &&
            (identical(other.relatedActivityId, relatedActivityId) ||
                other.relatedActivityId == relatedActivityId) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.isSent, isSent) || other.isSent == isSent) &&
            (identical(other.sentAt, sentAt) || other.sentAt == sentAt) &&
            (identical(other.readAt, readAt) || other.readAt == readAt) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      title,
      body,
      recipientId,
      recipientRole,
      relatedChildId,
      relatedActivityId,
      isRead,
      isSent,
      sentAt,
      readAt,
      priority,
      const DeepCollectionEquality().hash(_data),
      createdAt,
      expiresAt);

  /// Create a copy of NotificationItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationItemImplCopyWith<_$NotificationItemImpl> get copyWith =>
      __$$NotificationItemImplCopyWithImpl<_$NotificationItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationItemImplToJson(
      this,
    );
  }
}

abstract class _NotificationItem extends NotificationItem {
  const factory _NotificationItem(
          {required final String id,
          required final String type,
          required final String title,
          required final String body,
          required final String recipientId,
          required final String recipientRole,
          @JsonKey(name: 'related_child_id') final String? relatedChildId,
          @JsonKey(name: 'related_activity_id') final String? relatedActivityId,
          @JsonKey(name: 'is_read') required final bool isRead,
          @JsonKey(name: 'is_sent') required final bool isSent,
          @JsonKey(name: 'sent_at') final DateTime? sentAt,
          @JsonKey(name: 'read_at') final DateTime? readAt,
          @JsonKey(name: 'priority') required final String priority,
          final Map<String, dynamic>? data,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'expires_at') final DateTime? expiresAt}) =
      _$NotificationItemImpl;
  const _NotificationItem._() : super._();

  factory _NotificationItem.fromJson(Map<String, dynamic> json) =
      _$NotificationItemImpl.fromJson;

  @override
  String get id;
  @override
  String get type;
  @override
  String get title;
  @override
  String get body;
  @override
  String get recipientId;
  @override
  String get recipientRole;
  @override
  @JsonKey(name: 'related_child_id')
  String? get relatedChildId;
  @override
  @JsonKey(name: 'related_activity_id')
  String? get relatedActivityId;
  @override
  @JsonKey(name: 'is_read')
  bool get isRead;
  @override
  @JsonKey(name: 'is_sent')
  bool get isSent;
  @override
  @JsonKey(name: 'sent_at')
  DateTime? get sentAt;
  @override
  @JsonKey(name: 'read_at')
  DateTime? get readAt;
  @override
  @JsonKey(name: 'priority')
  String get priority;
  @override
  Map<String, dynamic>? get data;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'expires_at')
  DateTime? get expiresAt;

  /// Create a copy of NotificationItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationItemImplCopyWith<_$NotificationItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
