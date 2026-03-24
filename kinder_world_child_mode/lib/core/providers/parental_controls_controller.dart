import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ParentalControlsState {
  final bool dailyLimitEnabled;
  final double hoursPerDay;
  final bool breakRemindersEnabled;
  final bool ageAppropriateOnly;
  final bool blockEducationalContent;
  final bool requireApproval;
  final bool sleepModeEnabled;
  final TimeOfDay bedtime;
  final TimeOfDay wakeTime;

  const ParentalControlsState({
    this.dailyLimitEnabled = true,
    this.hoursPerDay = 2,
    this.breakRemindersEnabled = true,
    this.ageAppropriateOnly = true,
    this.blockEducationalContent = false,
    this.requireApproval = false,
    this.sleepModeEnabled = true,
    this.bedtime = const TimeOfDay(hour: 20, minute: 0),
    this.wakeTime = const TimeOfDay(hour: 7, minute: 0),
  });

  ParentalControlsState copyWith({
    bool? dailyLimitEnabled,
    double? hoursPerDay,
    bool? breakRemindersEnabled,
    bool? ageAppropriateOnly,
    bool? blockEducationalContent,
    bool? requireApproval,
    bool? sleepModeEnabled,
    TimeOfDay? bedtime,
    TimeOfDay? wakeTime,
  }) {
    return ParentalControlsState(
      dailyLimitEnabled: dailyLimitEnabled ?? this.dailyLimitEnabled,
      hoursPerDay: hoursPerDay ?? this.hoursPerDay,
      breakRemindersEnabled:
          breakRemindersEnabled ?? this.breakRemindersEnabled,
      ageAppropriateOnly: ageAppropriateOnly ?? this.ageAppropriateOnly,
      blockEducationalContent:
          blockEducationalContent ?? this.blockEducationalContent,
      requireApproval: requireApproval ?? this.requireApproval,
      sleepModeEnabled: sleepModeEnabled ?? this.sleepModeEnabled,
      bedtime: bedtime ?? this.bedtime,
      wakeTime: wakeTime ?? this.wakeTime,
    );
  }
}

class ParentalControlsController extends StateNotifier<ParentalControlsState> {
  ParentalControlsController() : super(const ParentalControlsState());

  void setDailyLimitEnabled(bool value) {
    state = state.copyWith(dailyLimitEnabled: value);
  }

  void setHoursPerDay(double value) {
    state = state.copyWith(hoursPerDay: value);
  }

  void setBreakRemindersEnabled(bool value) {
    state = state.copyWith(breakRemindersEnabled: value);
  }

  void setAgeAppropriateOnly(bool value) {
    state = state.copyWith(ageAppropriateOnly: value);
  }

  void setBlockEducationalContent(bool value) {
    state = state.copyWith(blockEducationalContent: value);
  }

  void setRequireApproval(bool value) {
    state = state.copyWith(requireApproval: value);
  }

  void setSleepModeEnabled(bool value) {
    state = state.copyWith(sleepModeEnabled: value);
  }

  void setBedtime(TimeOfDay value) {
    state = state.copyWith(bedtime: value);
  }

  void setWakeTime(TimeOfDay value) {
    state = state.copyWith(wakeTime: value);
  }
}

final parentalControlsProvider =
    StateNotifierProvider<ParentalControlsController, ParentalControlsState>(
        (ref) => ParentalControlsController());
