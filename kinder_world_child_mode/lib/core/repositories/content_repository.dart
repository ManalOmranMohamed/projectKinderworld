import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:kinder_world/core/models/activity.dart';
import 'package:kinder_world/core/models/child_profile.dart';
import 'package:logger/logger.dart';

/// Repository for content and activity operations
class ContentRepository {
  final Box _activityBox;
  final Logger _logger;

  ContentRepository({
    required Box activityBox,
    required Logger logger,
  })  : _activityBox = activityBox,
        _logger = logger;

  // ==================== CRUD OPERATIONS ====================

  /// Get all activities
  Future<List<Activity>> getAllActivities() async {
    try {
      final activities = <Activity>[];

      for (var key in _activityBox.keys) {
        final data = _activityBox.get(key);
        if (data != null) {
          try {
            final json = data is String
                ? jsonDecode(data)
                : Map<String, dynamic>.from(data);
            
            activities.add(Activity.fromJson(json));
          } catch (e) {
            _logger.e('Error parsing activity: $key, $e');
          }
        }
      }

      _logger.d('Retrieved ${activities.length} activities');
      return activities;
    } catch (e) {
      _logger.e('Error getting all activities: $e');
      return [];
    }
  }

  /// Get activity by ID
  Future<Activity?> getActivity(String activityId) async {
    try {
      final data = _activityBox.get(activityId);
      
      if (data == null) {
        _logger.w('Activity not found: $activityId');
        return null;
      }

      final json = data is String
          ? jsonDecode(data)
          : Map<String, dynamic>.from(data);

      return Activity.fromJson(json);
    } catch (e) {
      _logger.e('Error getting activity: $activityId, $e');
      return null;
    }
  }

  /// Save activity
  Future<Activity?> saveActivity(Activity activity) async {
    try {
      final json = activity.toJson();
      await _activityBox.put(activity.id, json);
      
      _logger.d('Activity saved: ${activity.id}');
      return activity;
    } catch (e) {
      _logger.e('Error saving activity: $e');
      return null;
    }
  }

  /// Save multiple activities
  Future<bool> saveActivities(List<Activity> activities) async {
    try {
      final map = {
        for (var activity in activities)
          activity.id: activity.toJson()
      };
      
      await _activityBox.putAll(map);
      _logger.d('Saved ${activities.length} activities');
      return true;
    } catch (e) {
      _logger.e('Error saving activities: $e');
      return false;
    }
  }

  /// Delete activity
  Future<bool> deleteActivity(String activityId) async {
    try {
      await _activityBox.delete(activityId);
      _logger.d('Activity deleted: $activityId');
      return true;
    } catch (e) {
      _logger.e('Error deleting activity: $activityId, $e');
      return false;
    }
  }

  // ==================== FILTERING ====================

  /// Get activities by category
  Future<List<Activity>> getActivitiesByCategory(String category) async {
    try {
      final allActivities = await getAllActivities();
      final filtered = allActivities
          .where((activity) => activity.category == category)
          .toList();
      
      _logger.d('Found ${filtered.length} activities in category: $category');
      return filtered;
    } catch (e) {
      _logger.e('Error filtering by category: $category, $e');
      return [];
    }
  }

  /// Get activities by type
  Future<List<Activity>> getActivitiesByType(String type) async {
    try {
      final allActivities = await getAllActivities();
      final filtered = allActivities
          .where((activity) => activity.type == type)
          .toList();
      
      _logger.d('Found ${filtered.length} activities of type: $type');
      return filtered;
    } catch (e) {
      _logger.e('Error filtering by type: $type, $e');
      return [];
    }
  }

  /// Get activities by aspect
  Future<List<Activity>> getActivitiesByAspect(String aspect) async {
    try {
      final allActivities = await getAllActivities();
      final filtered = allActivities
          .where((activity) => activity.aspect == aspect)
          .toList();
      
      _logger.d('Found ${filtered.length} activities for aspect: $aspect');
      return filtered;
    } catch (e) {
      _logger.e('Error filtering by aspect: $aspect, $e');
      return [];
    }
  }

  /// Get activities by difficulty
  Future<List<Activity>> getActivitiesByDifficulty(String difficulty) async {
    try {
      final allActivities = await getAllActivities();
      final filtered = allActivities
          .where((activity) => activity.difficulty == difficulty)
          .toList();
      
      _logger.d('Found ${filtered.length} activities with difficulty: $difficulty');
      return filtered;
    } catch (e) {
      _logger.e('Error filtering by difficulty: $difficulty, $e');
      return [];
    }
  }

  // ==================== SORTING ====================

  /// Get popular activities
  Future<List<Activity>> getPopularActivities({int limit = 10}) async {
    try {
      final allActivities = await getAllActivities();
      
      allActivities.sort((a, b) => b.playCount.compareTo(a.playCount));
      
      final popular = allActivities.take(limit).toList();
      _logger.d('Retrieved ${popular.length} popular activities');
      return popular;
    } catch (e) {
      _logger.e('Error getting popular activities: $e');
      return [];
    }
  }

  /// Get recently added activities
  Future<List<Activity>> getRecentlyAddedActivities({int limit = 10}) async {
    try {
      final allActivities = await getAllActivities();
      
      allActivities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      final recent = allActivities.take(limit).toList();
      _logger.d('Retrieved ${recent.length} recently added activities');
      return recent;
    } catch (e) {
      _logger.e('Error getting recently added activities: $e');
      return [];
    }
  }

  // ==================== PERSONALIZATION ====================

  /// Get recommended activities for a child
  Future<List<Activity>> getRecommendedActivities(ChildProfile child) async {
    try {
      final allActivities = await getAllActivities();
      
      // Filter by age appropriateness
      final ageAppropriate = allActivities
          .where((activity) => activity.isAppropriateForAge(child.age))
          .toList();
      
      // Score activities based on child's interests and level
      final scored = ageAppropriate.map((activity) {
        double score = 0.0;
        
        // Interest match
        final interestMatches = activity.tags
            .where((tag) => child.interests.contains(tag))
            .length;
        score += interestMatches * 10;
        
        // Level appropriateness
        final levelDiff = (activity.difficultyLevel - child.level).abs();
        if (levelDiff <= 1) {
          score += 5;
        } else if (levelDiff <= 2) {
          score += 2;
        }
        
        // Rating boost
        if (activity.averageRating != null) {
          score += activity.averageRating! * 2;
        }
        
        return MapEntry(activity, score);
      }).toList();
      
      // Sort by score
      scored.sort((a, b) => b.value.compareTo(a.value));
      
      // Return top 10
      final recommended = scored.take(10).map((e) => e.key).toList();
      _logger.d('Generated ${recommended.length} recommendations for ${child.name}');
      return recommended;
    } catch (e) {
      _logger.e('Error getting recommended activities: $e');
      return [];
    }
  }

  /// Get activities appropriate for a child
  Future<List<Activity>> getActivitiesForChild(ChildProfile child) async {
    try {
      final allActivities = await getAllActivities();
      
      final appropriate = allActivities
          .where((activity) => activity.isAppropriateForAge(child.age))
          .toList();
      
      _logger.d('Found ${appropriate.length} activities for ${child.name}');
      return appropriate;
    } catch (e) {
      _logger.e('Error getting activities for child: $e');
      return [];
    }
  }

  // ==================== SEARCH ====================

  /// Search activities by query
  Future<List<Activity>> searchActivities(String query) async {
    try {
      if (query.isEmpty) return [];
      
      final allActivities = await getAllActivities();
      final searchTerm = query.toLowerCase();
      
      final results = allActivities.where((activity) {
        return activity.title.toLowerCase().contains(searchTerm) ||
               activity.description.toLowerCase().contains(searchTerm) ||
               activity.tags.any((tag) => tag.toLowerCase().contains(searchTerm));
      }).toList();
      
      _logger.d('Search for "$query" found ${results.length} results');
      return results;
    } catch (e) {
      _logger.e('Error searching activities: $query, $e');
      return [];
    }
  }

  // ==================== OFFLINE SUPPORT ====================

  /// Get offline available activities
  Future<List<Activity>> getOfflineActivities() async {
    try {
      final allActivities = await getAllActivities();
      
      final offline = allActivities
          .where((activity) => activity.isOfflineAvailable)
          .toList();
      
      _logger.d('Found ${offline.length} offline activities');
      return offline;
    } catch (e) {
      _logger.e('Error getting offline activities: $e');
      return [];
    }
  }

  /// Download activity for offline use
  Future<bool> downloadForOffline(String activityId) async {
    try {
      // TODO: Implement actual download logic
      // This would involve downloading content files
      
      final activity = await getActivity(activityId);
      if (activity == null) return false;
      
      // Mark as offline available
      final updated = activity.copyWith(isOfflineAvailable: true);
      await saveActivity(updated);
      
      _logger.d('Activity marked for offline: $activityId');
      return true;
    } catch (e) {
      _logger.e('Error downloading for offline: $activityId, $e');
      return false;
    }
  }

  // ==================== ACTIVITY INTERACTION ====================

  /// Increment play count
  Future<bool> incrementPlayCount(String activityId) async {
    try {
      final activity = await getActivity(activityId);
      if (activity == null) return false;
      
      final updated = activity.copyWith(
        playCount: activity.playCount + 1,
        updatedAt: DateTime.now(),
      );
      
      await saveActivity(updated);
      _logger.d('Play count incremented for: $activityId');
      return true;
    } catch (e) {
      _logger.e('Error incrementing play count: $activityId, $e');
      return false;
    }
  }

  // ==================== SYNC ====================

  /// Sync with server
  Future<bool> syncWithServer() async {
    try {
      // TODO: Implement actual server sync
      _logger.d('Sync with server called (not implemented)');
      return true;
    } catch (e) {
      _logger.e('Error syncing with server: $e');
      return false;
    }
  }

  // ==================== STATISTICS ====================

  /// Get content statistics
  Future<Map<String, dynamic>> getContentStats() async {
    try {
      final allActivities = await getAllActivities();
      
      final stats = {
        'totalActivities': allActivities.length,
        'byCategory': <String, int>{},
        'byType': <String, int>{},
        'byAspect': <String, int>{},
        'offlineCount': allActivities.where((a) => a.isOfflineAvailable).length,
        'premiumCount': allActivities.where((a) => a.isPremium).length,
      };
      
      // Count by category
      final byCategory = stats['byCategory'] as Map<String, int>;
      final byType = stats['byType'] as Map<String, int>;
      final byAspect = stats['byAspect'] as Map<String, int>;

      for (var activity in allActivities) {
        byCategory[activity.category] = (byCategory[activity.category] ?? 0) + 1;
        byType[activity.type] = (byType[activity.type] ?? 0) + 1;
        byAspect[activity.aspect] = (byAspect[activity.aspect] ?? 0) + 1;
      }
      
      return stats;
    } catch (e) {
      _logger.e('Error getting content stats: $e');
      return {};
    }
  }
}