import 'package:flutter/material.dart';
import 'package:kinder_world/core/theme/app_colors.dart';

class PicturePasswordOption {
  final String id;
  final IconData icon;
  final Color color;

  const PicturePasswordOption({
    required this.id,
    required this.icon,
    required this.color,
  });
}

const List<PicturePasswordOption> picturePasswordOptions = [
  PicturePasswordOption(
    id: 'apple',
    icon: Icons.eco,
    color: AppColors.success,
  ),
  PicturePasswordOption(
    id: 'ball',
    icon: Icons.sports_soccer,
    color: AppColors.info,
  ),
  PicturePasswordOption(
    id: 'cat',
    icon: Icons.pets,
    color: AppColors.primary,
  ),
  PicturePasswordOption(
    id: 'dog',
    icon: Icons.emoji_nature,
    color: AppColors.warning,
  ),
  PicturePasswordOption(
    id: 'elephant',
    icon: Icons.park,
    color: AppColors.secondary,
  ),
  PicturePasswordOption(
    id: 'fish',
    icon: Icons.set_meal,
    color: AppColors.entertaining,
  ),
  PicturePasswordOption(
    id: 'guitar',
    icon: Icons.music_note,
    color: AppColors.skillful,
  ),
  PicturePasswordOption(
    id: 'house',
    icon: Icons.home,
    color: AppColors.educational,
  ),
  PicturePasswordOption(
    id: 'icecream',
    icon: Icons.cake,
    color: AppColors.behavioral,
  ),
  PicturePasswordOption(
    id: 'jelly',
    icon: Icons.emoji_food_beverage,
    color: AppColors.streakColor,
  ),
  PicturePasswordOption(
    id: 'kite',
    icon: Icons.toys,
    color: AppColors.parentModeColor,
  ),
  PicturePasswordOption(
    id: 'lion',
    icon: Icons.face,
    color: AppColors.xpColor,
  ),
];

final Map<String, PicturePasswordOption> picturePasswordOptionsById = {
  for (final option in picturePasswordOptions) option.id: option,
};

class PicturePasswordRow extends StatelessWidget {
  const PicturePasswordRow({
    super.key,
    required this.picturePassword,
    this.size = 18,
    this.color,
    this.showPlaceholders = true,
    this.useOptionColor = true,
  });

  final List<String> picturePassword;
  final double size;
  final Color? color;
  final bool showPlaceholders;
  final bool useOptionColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fallbackColor = color ?? colors.primary;
    final slots = showPlaceholders
        ? List<String?>.generate(
            3,
            (i) => i < picturePassword.length ? picturePassword[i] : null,
          )
        : picturePassword.take(3).map<String?>((id) => id).toList();

    if (slots.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: slots.map((slot) => _buildSlot(slot, fallbackColor, colors)).toList(),
    );
  }

  Widget _buildSlot(String? id, Color fallbackColor, ColorScheme colors) {
    final option = id == null ? null : picturePasswordOptionsById[id];
    final resolvedColor =
        useOptionColor ? option?.color ?? fallbackColor : fallbackColor;
    
    // Ensure better visibility in both light and dark themes
    final borderColor = resolvedColor.withValues(alpha: 0.6);
    final fillColor = id == null
      ? colors.surfaceContainerHighest.withValues(alpha: 0.5)
      : resolvedColor.withValues(alpha: 0.15);
    final iconColor = resolvedColor; // Use full opacity for icons
    
    final icon = option?.icon;
    final fallback = id == null || id.isEmpty ? '?' : id[0].toUpperCase();

    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: fillColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: id == null
          ? const SizedBox.shrink()
          : Center(
              child: icon != null
                  ? Icon(icon, size: size * 0.6, color: iconColor)
                  : Text(
                      fallback,
                      style: TextStyle(
                        fontSize: size * 0.55,
                        fontWeight: FontWeight.w600,
                        color: iconColor,
                      ),
                    ),
            ),
    );
  }
}
