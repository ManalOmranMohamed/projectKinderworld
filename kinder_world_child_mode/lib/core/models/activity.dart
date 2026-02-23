// Workaround for analyzer: allow JsonKey on Freezed constructor params
// (some analyzer versions report 'invalid_annotation_target')
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity.freezed.dart';
part 'activity.g.dart';

@freezed
class Activity with _$Activity {
  const factory Activity({
    required String id,
    required String title,
    required String description,
    required String category,
    required String type,
    required String aspect,
    required List<String> ageRange,
    required String difficulty,
    required int duration,
    required int xpReward,
    required String thumbnailUrl,
    String? contentUrl,
    required List<String> tags,
    required List<String> learningObjectives,
    String? instructions,
    List<String>? materialsNeeded,
    @JsonKey(name: 'is_offline_available') required bool isOfflineAvailable,
    @JsonKey(name: 'is_premium') required bool isPremium,
    @JsonKey(name: 'parent_approval_required') required bool parentApprovalRequired,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'completion_rate') double? completionRate,
    @JsonKey(name: 'average_rating') double? averageRating,
    @JsonKey(name: 'play_count') required int playCount,
  }) = _Activity;

  const Activity._();

  factory Activity.fromJson(Map<String, dynamic> json) => 
      _$ActivityFromJson(json);

  // Check if activity is appropriate for age
  bool isAppropriateForAge(int age) {
    if (ageRange.isEmpty) return true;
    
    for (final range in ageRange) {
      if (range.contains('-')) {
        final parts = range.split('-');
        if (parts.length == 2) {
          final minAge = int.tryParse(parts[0]) ?? 0;
          final maxAge = int.tryParse(parts[1]) ?? 99;
          if (age >= minAge && age <= maxAge) return true;
        }
      } else {
        final targetAge = int.tryParse(range);
        if (targetAge == age) return true;
      }
    }
    return false;
  }

  // Get difficulty level as integer
  int get difficultyLevel {
    switch (difficulty) {
      case 'beginner':
        return 1;
      case 'easy':
        return 2;
      case 'medium':
        return 3;
      case 'hard':
        return 4;
      case 'expert':
        return 5;
      default:
        return 2;
    }
  }

  // Get aspect color
  String get aspectColor {
    switch (aspect) {
      case 'behavioral':
        return '#E91E63';
      case 'skillful':
        return '#9C27B0';
      case 'educational':
        return '#3F51B5';
      case 'entertaining':
        return '#00BCD4';
      default:
        return '#4A86E8';
    }
  }

  // Check if activity is interactive
  bool get isInteractive {
    return type == 'game' || type == 'quiz' || type == 'interactive_story';
  }

  // Get estimated completion time as string
  String get estimatedTime {
    if (duration < 60) {
      return '$duration min';
    } else {
      final hours = duration ~/ 60;
      final minutes = duration % 60;
      if (minutes == 0) {
        return '$hours hour${hours > 1 ? 's' : ''}';
      } else {
        return '$hours hour${hours > 1 ? 's' : ''} $minutes min';
      }
    }
  }

  // Get rating as stars
  int get ratingStars {
    if (averageRating == null) return 0;
    return (averageRating! * 2).round() ~/ 2;
  }
}

// Activity categories
class ActivityCategories {
  static const String mathematics = 'mathematics';
  static const String science = 'science';
  static const String reading = 'reading';
  static const String history = 'history';
  static const String geography = 'geography';
  static const String languages = 'languages';
  static const String socialSkills = 'social_skills';
  static const String emotionalIntelligence = 'emotional_intelligence';
  static const String creativity = 'creativity';
  static const String motorSkills = 'motor_skills';
  static const String problemSolving = 'problem_solving';
  static const String music = 'music';
  static const String games = 'games';
  static const String stories = 'stories';
  static const String videos = 'videos';
  
  static const List<String> all = [
    mathematics, science, reading, history, geography, languages,
    socialSkills, emotionalIntelligence, creativity, motorSkills,
    problemSolving, music, games, stories, videos
  ];

  static String getDisplayName(String category) {
    switch (category) {
      case mathematics: return 'Mathematics';
      case science: return 'Science';
      case reading: return 'Reading';
      case history: return 'History';
      case geography: return 'Geography';
      case languages: return 'Languages';
      case socialSkills: return 'Social Skills';
      case emotionalIntelligence: return 'Emotional Intelligence';
      case creativity: return 'Creativity';
      case motorSkills: return 'Motor Skills';
      case problemSolving: return 'Problem Solving';
      case music: return 'Music';
      case games: return 'Games';
      case stories: return 'Stories';
      case videos: return 'Videos';
      default: return category;
    }
  }
}

// Activity types
class ActivityTypes {
  static const String lesson = 'lesson';
  static const String game = 'game';
  static const String quiz = 'quiz';
  static const String story = 'story';
  static const String video = 'video';
  static const String interactiveStory = 'interactive_story';
  static const String craft = 'craft';
  static const String song = 'song';
  static const String challenge = 'challenge';
  static const String simulation = 'simulation';
  
  static const List<String> all = [
    lesson, game, quiz, story, video, interactiveStory,
    craft, song, challenge, simulation
  ];

  static String getDisplayName(String type) {
    switch (type) {
      case lesson: return 'Lesson';
      case game: return 'Game';
      case quiz: return 'Quiz';
      case story: return 'Story';
      case video: return 'Video';
      case interactiveStory: return 'Interactive Story';
      case craft: return 'Craft';
      case song: return 'Song';
      case challenge: return 'Challenge';
      case simulation: return 'Simulation';
      default: return type;
    }
  }
}

// Activity aspects (from SRS)
class ActivityAspects {
  static const String behavioral = 'behavioral';
  static const String skillful = 'skillful';
  static const String educational = 'educational';
  static const String entertaining = 'entertaining';
  
  static const List<String> all = [
    behavioral, skillful, educational, entertaining
  ];
  
  static String getDisplayName(String aspect) {
    switch (aspect) {
      case behavioral:
        return 'Behavioral';
      case skillful:
        return 'Skillful';
      case educational:
        return 'Educational';
      case entertaining:
        return 'Entertaining';
      default:
        return aspect;
    }
  }
}

// Difficulty levels
class DifficultyLevels {
  static const String beginner = 'beginner';
  static const String easy = 'easy';
  static const String medium = 'medium';
  static const String hard = 'hard';
  static const String expert = 'expert';
  
  static const List<String> all = [
    beginner, easy, medium, hard, expert
  ];
  
  static String getDisplayName(String difficulty) {
    switch (difficulty) {
      case beginner:
        return 'Beginner';
      case easy:
        return 'Easy';
      case medium:
        return 'Medium';
      case hard:
        return 'Hard';
      case expert:
        return 'Expert';
      default:
        return difficulty;
    }
  }
}