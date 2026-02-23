import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kinder_world/core/theme/theme_palette.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeState {
  final String paletteId;
  final ThemeMode mode;

  const ThemeState({
    required this.paletteId,
    required this.mode,
  });

  ThemeState copyWith({
    String? paletteId,
    ThemeMode? mode,
  }) {
    return ThemeState(
      paletteId: paletteId ?? this.paletteId,
      mode: mode ?? this.mode,
    );
  }
}

class ThemeController extends StateNotifier<ThemeState> {
  static const _paletteKey = 'theme_palette_id';
  static const _modeKey = 'theme_mode';

  ThemeController()
      : super(
          const ThemeState(
            paletteId: ThemePalettes.defaultPaletteId,
            mode: ThemeMode.light,
          ),
        ) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPalette =
        prefs.getString(_paletteKey) ?? ThemePalettes.defaultPaletteId;
    final savedModeIndex = prefs.getInt(_modeKey) ?? ThemeMode.light.index;
    final clampedIndex =
      savedModeIndex.clamp(0, ThemeMode.values.length - 1).toInt();
    final mode = ThemeMode.values[clampedIndex];

    state = state.copyWith(paletteId: savedPalette, mode: mode);
  }

  Future<void> setPalette(String paletteId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_paletteKey, paletteId);
    state = state.copyWith(paletteId: paletteId);
  }

  Future<void> setMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_modeKey, mode.index);
    state = state.copyWith(mode: mode);
  }
}

final themeControllerProvider =
    StateNotifierProvider<ThemeController, ThemeState>((ref) {
  return ThemeController();
});

final themePaletteProvider = Provider<ThemePalette>((ref) {
  final state = ref.watch(themeControllerProvider);
  return ThemePalettes.byId(state.paletteId);
});
