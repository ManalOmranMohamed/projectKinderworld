import 'package:flutter/material.dart';
import 'package:kinder_world/core/constants/app_constants.dart';
import 'package:kinder_world/core/theme/theme_palette.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme({required ThemePalette palette, bool isChildFriendly = true}) {
    final scheme = palette.colorScheme(Brightness.light).copyWith(
      surface: palette.lightSurface,
    );
    return _themeFromScheme(scheme, isChildFriendly);
  }

  static ThemeData darkTheme({required ThemePalette palette, bool isChildFriendly = true}) {
    final scheme = palette.colorScheme(Brightness.dark).copyWith(
      surface: palette.darkSurface,
    );
    return _themeFromScheme(scheme, isChildFriendly);
  }

  static ThemeData _themeFromScheme(ColorScheme scheme, bool isChildFriendly) {
    final textPrimary = scheme.brightness == Brightness.dark
        ? scheme.onSurface.withValues(alpha: 0.92)
        : scheme.onSurface;
    final textSecondary = scheme.brightness == Brightness.dark
        ? scheme.onSurface.withValues(alpha: 0.72)
        : scheme.onSurfaceVariant;

    final textTheme = TextTheme(
      displayLarge: TextStyle(
        fontSize: isChildFriendly ? 32 : 28,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: isChildFriendly ? 28 : 24,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: isChildFriendly ? 24 : 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: isChildFriendly ? 22 : 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: isChildFriendly ? AppConstants.fontSize : 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: isChildFriendly ? AppConstants.fontSize : 16,
        color: textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: isChildFriendly ? 16 : 14,
        color: textSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: isChildFriendly ? 14 : 12,
        color: textSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: isChildFriendly ? AppConstants.fontSize : 16,
        fontWeight: FontWeight.w600,
        color: scheme.onPrimary,
      ),
      labelMedium: TextStyle(
        fontSize: isChildFriendly ? 14 : 12,
        fontWeight: FontWeight.w600,
        color: textSecondary,
      ),
      labelSmall: TextStyle(
        fontSize: isChildFriendly ? 12 : 11,
        color: textSecondary,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: scheme.brightness,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: 'SFPro',
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: textPrimary,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: scheme.shadow.withValues(alpha: 0.08),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(AppConstants.minTouchTarget, AppConstants.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.secondaryContainer,
          foregroundColor: scheme.onSecondaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      iconTheme: IconThemeData(color: textPrimary),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        disabledColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        selectedColor: scheme.secondaryContainer,
        secondarySelectedColor: scheme.secondaryContainer,
        labelStyle: textTheme.bodySmall!,
        secondaryLabelStyle: textTheme.bodySmall!,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: textTheme.bodyMedium?.copyWith(color: textSecondary),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: textSecondary.withValues(alpha: 0.9),
        ),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: textSecondary,
        textColor: textPrimary,
        tileColor: scheme.surface,
      ),
    );
  }
}
