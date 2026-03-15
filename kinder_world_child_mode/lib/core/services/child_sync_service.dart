import 'package:kinder_world/core/constants/app_constants.dart';
import 'package:kinder_world/core/api/children_api.dart';
import 'package:kinder_world/core/models/child_profile.dart';
import 'package:kinder_world/core/models/user.dart';
import 'package:kinder_world/core/repositories/child_repository.dart';
import 'package:kinder_world/core/storage/secure_storage.dart';
import 'package:logger/logger.dart';

class ChildSyncService {
  final ChildRepository _childRepository;
  final ChildrenApi _childrenApi;
  final SecureStorage _secureStorage;
  final Logger _logger;

  ChildSyncService({
    required ChildRepository childRepository,
    required ChildrenApi childrenApi,
    required SecureStorage secureStorage,
    required Logger logger,
  })  : _childRepository = childRepository,
        _childrenApi = childrenApi,
        _secureStorage = secureStorage,
        _logger = logger;

  Future<void> syncChildren() async {
    try {
      final token = await _secureStorage.getAuthToken();
      if (token == null || token.isEmpty) return;
      final role = await _secureStorage.getUserRole();
      if (role != UserRoles.parent) return;

      final parentId = await _secureStorage.getParentId();
      final parentEmail = await _secureStorage.getParentEmail();

      final apiChildren = await _childrenApi.fetchChildren();
      for (final childData in apiChildren) {
        final childId = _parseChildId(childData);
        if (childId == null || childId.isEmpty) continue;
        final existing = await _childRepository.getChildProfile(childId);
        final merged = _mergeChildProfileFromApi(
          childData,
          existing: existing,
          parentId: parentId ?? 'local',
          parentEmail: parentEmail,
        );
        if (merged == null) continue;
        if (existing == null) {
          await _childRepository.createChildProfile(merged);
        } else {
          await _childRepository.updateChildProfile(merged);
        }
      }
    } catch (e) {
      _logger.e('Error syncing children: $e');
    }
  }

  String? _parseChildId(Map<String, dynamic> data) {
    final raw = data['id'] ?? data['child_id'] ?? data['childId'];
    return raw?.toString();
  }

  int _parseInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  DateTime _parseDate(dynamic value, DateTime fallback) {
    if (value is DateTime) return value;
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is double) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return fallback;
  }

  DateTime? _parseNullableDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is double) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return null;
  }

  List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return const [];
  }

  List<String>? _parseNullableStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return null;
  }

  DateTime? _parseBirthDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is double) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    return null;
  }

  int _ageFromBirthDate(DateTime? birthDate) {
    if (birthDate == null) return 0;
    final now = DateTime.now();
    var age = now.year - birthDate.year;
    final hasHadBirthday = (now.month > birthDate.month) ||
        (now.month == birthDate.month && now.day >= birthDate.day);
    if (!hasHadBirthday) age -= 1;
    return age.clamp(0, 120);
  }

  int _resolveAgeFromApi(Map<String, dynamic> data, ChildProfile? existing) {
    final apiAge = _parseInt(data['age'], 0);
    final birthDate = _parseBirthDate(
      data['birthdate'] ??
          data['birth_date'] ??
          data['date_of_birth'] ??
          data['dob'],
    );
    final computedAge = _ageFromBirthDate(birthDate);

    if (apiAge > 0) return apiAge;
    if (computedAge > 0) return computedAge;
    return existing?.age ?? 0;
  }

  ChildProfile? _mergeChildProfileFromApi(
    Map<String, dynamic> data, {
    ChildProfile? existing,
    String? parentId,
    String? parentEmail,
  }) {
    final childId = _parseChildId(data);
    if (childId == null || childId.isEmpty) return null;

    final now = DateTime.now();
    final apiName = data['name']?.toString().trim();
    final resolvedName = (apiName != null && apiName.isNotEmpty)
        ? apiName
        : (existing?.name ?? childId);
    final age = _resolveAgeFromApi(data, existing);
    final existingLevel = existing?.level ?? 0;
    final level =
        existingLevel > 0 ? existingLevel : _parseInt(data['level'], 1);
    final avatar = existing?.avatar ??
        data['avatar']?.toString() ??
        AppConstants.defaultChildAvatar;
    final resolvedAvatarPath = existing?.avatarPath.isNotEmpty == true
        ? existing!.avatarPath
        : (avatar.isNotEmpty ? avatar : AppConstants.defaultChildAvatar);
    final picturePassword = (existing?.picturePassword.isNotEmpty ?? false)
        ? existing!.picturePassword
        : _parseStringList(data['picture_password']);
    final createdAt =
        existing?.createdAt ?? _parseDate(data['created_at'], now);
    final updatedAt = _parseDate(data['updated_at'], now);
    final lastSession =
        existing?.lastSession ?? _parseNullableDate(data['last_session']);

    return ChildProfile(
      id: childId,
      name: resolvedName,
      age: age,
      avatar: avatar,
      avatarPath: resolvedAvatarPath,
      interests: existing?.interests ?? _parseStringList(data['interests']),
      level: level,
      xp: existing?.xp ?? _parseInt(data['xp'], 0),
      streak: existing?.streak ?? _parseInt(data['streak'], 0),
      favorites: existing?.favorites ?? _parseStringList(data['favorites']),
      parentId: parentId ?? existing?.parentId ?? 'local',
      parentEmail: existing?.parentEmail ??
          parentEmail ??
          data['parent_email']?.toString(),
      picturePassword: picturePassword,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastSession: lastSession,
      totalTimeSpent:
          existing?.totalTimeSpent ?? _parseInt(data['total_time_spent'], 0),
      activitiesCompleted: existing?.activitiesCompleted ??
          _parseInt(data['activities_completed'], 0),
      currentMood: existing?.currentMood ?? data['current_mood']?.toString(),
      learningStyle:
          existing?.learningStyle ?? data['learning_style']?.toString(),
      specialNeeds: existing?.specialNeeds ??
          _parseNullableStringList(data['special_needs']),
      accessibilityNeeds: existing?.accessibilityNeeds ??
          _parseNullableStringList(data['accessibility_needs']),
    );
  }
}
