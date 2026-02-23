import 'package:flutter/material.dart';
import 'package:kinder_world/core/theme/app_colors.dart';

class ThemePalette {
  final String id;
  final String name;
  final Color seedColor;
  final Color primary;
  final Color secondary;
  final Color lightBackground;
  final Color lightSurface;
  final Color darkBackground;
  final Color darkSurface;

  const ThemePalette({
    required this.id,
    required this.name,
    required this.seedColor,
    required this.primary,
    required this.secondary,
    required this.lightBackground,
    required this.lightSurface,
    required this.darkBackground,
    required this.darkSurface,
  });

  ColorScheme colorScheme(Brightness brightness) {
    final base = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    final isDark = brightness == Brightness.dark;
    return base.copyWith(
      primary: primary,
      secondary: secondary,
      surface: isDark ? darkSurface : lightSurface,
    );
  }
}

class ThemePalettes {
  ThemePalettes._();

  static const String defaultPaletteId = 'default';

  static const ThemePalette defaultPalette = ThemePalette(
    id: defaultPaletteId,
    name: 'Default',
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    lightBackground: AppColors.background,
    lightSurface: AppColors.surface,
    darkBackground: AppColors.nightModeBackground,
    darkSurface: AppColors.nightModeSurface,
  );

  static const ThemePalette blue = ThemePalette(
    id: 'blue',
    name: 'Ocean Blue',
    seedColor: Color(0xFF1E88E5),
    primary: Color(0xFF1E88E5),
    secondary: Color(0xFF26C6DA),
    lightBackground: AppColors.background,
    lightSurface: AppColors.surface,
    darkBackground: AppColors.nightModeBackground,
    darkSurface: AppColors.nightModeSurface,
  );

  static const ThemePalette purple = ThemePalette(
    id: 'purple',
    name: 'Purple Night',
    seedColor: Color(0xFF7B61FF),
    primary: Color(0xFF7B61FF),
    secondary: Color(0xFFB39DDB),
    lightBackground: AppColors.background,
    lightSurface: AppColors.surface,
    darkBackground: AppColors.nightModeBackground,
    darkSurface: AppColors.nightModeSurface,
  );

  static const ThemePalette green = ThemePalette(
    id: 'green',
    name: 'Forest Green',
    seedColor: Color(0xFF2E7D32),
    primary: Color(0xFF2E7D32),
    secondary: Color(0xFF66BB6A),
    lightBackground: AppColors.background,
    lightSurface: AppColors.surface,
    darkBackground: AppColors.nightModeBackground,
    darkSurface: AppColors.nightModeSurface,
  );

  static const ThemePalette sunset = ThemePalette(
    id: 'sunset',
    name: 'Sunset Orange',
    seedColor: Color(0xFFFF7043),
    primary: Color(0xFFFF7043),
    secondary: Color(0xFFFFB74D),
    lightBackground: AppColors.background,
    lightSurface: AppColors.surface,
    darkBackground: AppColors.nightModeBackground,
    darkSurface: AppColors.nightModeSurface,
  );

  static const List<ThemePalette> all = [
    defaultPalette,
    blue,
    purple,
    green,
    sunset,
  ];

  static ThemePalette byId(String id) {
    return all.firstWhere(
      (palette) => palette.id == id,
      orElse: () => defaultPalette,
    );
  }
}
