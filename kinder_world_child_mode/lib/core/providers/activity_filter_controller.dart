import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kinder_world/core/models/activity.dart';
import 'package:kinder_world/core/providers/child_session_controller.dart';
import 'package:kinder_world/core/providers/content_controller.dart';
import 'package:kinder_world/core/providers/parental_controls_controller.dart';

class ActivityFilterState {
  final String selectedAspect;
  final String? selectedCategory;
  final String? selectedDifficulty;

  const ActivityFilterState({
    this.selectedAspect = ActivityAspects.educational,
    this.selectedCategory,
    this.selectedDifficulty,
  });

  static const _unset = Object();

  ActivityFilterState copyWith({
    String? selectedAspect,
    Object? selectedCategory = _unset,
    Object? selectedDifficulty = _unset,
  }) {
    return ActivityFilterState(
      selectedAspect: selectedAspect ?? this.selectedAspect,
      selectedCategory: selectedCategory == _unset
          ? this.selectedCategory
          : selectedCategory as String?,
      selectedDifficulty: selectedDifficulty == _unset
          ? this.selectedDifficulty
          : selectedDifficulty as String?,
    );
  }

  bool get hasActiveFilters => selectedCategory != null || selectedDifficulty != null;
}

class ActivityFilterController extends StateNotifier<ActivityFilterState> {
  ActivityFilterController() : super(const ActivityFilterState());

  void selectAspect(String aspect) {
    state = state.copyWith(selectedAspect: aspect);
  }

  void selectCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  void selectDifficulty(String? difficulty) {
    state = state.copyWith(selectedDifficulty: difficulty);
  }

  void clearFilters() {
    state = const ActivityFilterState();
  }
}

final activityFilterControllerProvider =
    StateNotifierProvider<ActivityFilterController, ActivityFilterState>(
        (ref) => ActivityFilterController());

final filteredActivitiesProvider = Provider<List<Activity>>((ref) {
  final activities = ref.watch(allActivitiesProvider);
  final filters = ref.watch(activityFilterControllerProvider);
  final controls = ref.watch(parentalControlsProvider);
  final childProfile =
      ref.watch(childSessionControllerProvider.select((state) => state.childProfile));

  return activities.where((activity) {
    if (activity.aspect != filters.selectedAspect) {
      return false;
    }

    if (filters.selectedCategory != null &&
        activity.category != filters.selectedCategory) {
      return false;
    }

    if (filters.selectedDifficulty != null &&
        activity.difficulty != filters.selectedDifficulty) {
      return false;
    }

    if (controls.blockEducationalContent &&
        activity.aspect == ActivityAspects.educational) {
      return false;
    }

    if (controls.requireApproval && activity.parentApprovalRequired) {
      // Assumption: when approval is required, hide activities that still need approval.
      return false;
    }

    if (controls.ageAppropriateOnly && childProfile != null) {
      // Assumption: without a child profile, we cannot check age ranges.
      if (!activity.isAppropriateForAge(childProfile.age)) {
        return false;
      }
    }

    return true;
  }).toList(growable: false);
});
