import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors - High contrast
  static const Color primary = Color(0xFF1976D2); // Strong blue
  static const Color primaryDark = Color(0xFF004BA0);
  static const Color primaryLight = Color(0xFF63A4FF);

  // Secondary Colors
  static const Color secondary = Color(0xFFFF9800); // Strong orange
  static const Color secondaryDark = Color(0xFFC66900);
  static const Color secondaryLight = Color(0xFFFFC947);

  // Accent Colors
  static const Color success = Color(0xFF388E3C); // Strong green
  static const Color warning = Color(0xFFFBC02D); // Strong yellow
  static const Color error = Color(0xFFD32F2F);   // Strong red
  static const Color info = Color(0xFF0288D1);    // Strong cyan

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF4F6FA);
  static const Color grey = Color(0xFF8C9299);
  static const Color darkGrey = Color(0xFF464C52);
  static const Color black = Color(0xFF1C1F23);

  // Background Colors
  static const Color background = Color(0xFFFFFFFF); // Always white
  static const Color surface = Color(0xFFFFFFFF);    // Always white
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Text Colors
  static const Color textPrimary = Color(0xFF262A2E);
  static const Color textSecondary = Color(0xFF4F555C);
  static const Color textDisabled = Color(0xFF8E94A0);
  static const Color textHint = Color(0xFF626872);
  static const Color textIcon = Color(0xFF5A5F69);

  // Child-friendly colors for different aspects (unchanged)
  static const Color behavioral = Color(0xFFE91E63);
  static const Color skillful = Color(0xFF9C27B0);
  static const Color educational = Color(0xFF3F51B5);
  static const Color entertaining = Color(0xFF00BCD4);

  // Special modes (not used)
  static const Color nightModeBackground = Color(0xFF0F1115);
  static const Color nightModeSurface = Color(0xFF1B1F26);
  static const Color nightModeText = Color(0xFFE8EAF0);

  // Eye-friendly colors (not used)
  static const Color eyeFriendlyBackground = Color(0xFFFFFFFF);
  static const Color eyeFriendlyText = Color(0xFF000000);

  // High contrast for accessibility (not used)
  static const Color highContrastBackground = Color(0xFFFFFFFF);
  static const Color highContrastText = Color(0xFF000000);

  // Progress colors
  static const Color progressStart = Color(0xFFE3F2FD);
  static const Color progressEnd = Color(0xFF1976D2);
  static const Color xpColor = Color(0xFFFFD700);
  static const Color streakColor = Color(0xFFFF5722);
  
  // Mode colors
  static const Color parentModeColor = Color(0xFF2E7D32);
}
