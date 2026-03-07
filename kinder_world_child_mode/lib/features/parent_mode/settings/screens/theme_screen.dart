import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kinder_world/core/localization/app_localizations.dart';
import 'package:kinder_world/core/providers/theme_provider.dart';
import 'package:kinder_world/core/theme/theme_palette.dart';
import 'package:kinder_world/core/widgets/parent_design_system.dart';

class ParentThemeScreen extends ConsumerWidget {
  const ParentThemeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final themeSettings = ref.watch(themeControllerProvider);

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: colors.onSurface),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/parent/settings');
            }
          },
        ),
        title: Text(
          l10n.theme,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
              height: 1,
              color: colors.outlineVariant.withValues(alpha: 0.4)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Appearance Mode ─────────────────────────────────────────
              ParentCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ParentSectionHeader(title: l10n.mode),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _ModeButton(
                          icon: Icons.light_mode_rounded,
                          label: l10n.lightMode,
                          isSelected:
                              themeSettings.mode == ThemeMode.light,
                          onTap: () => ref
                              .read(themeControllerProvider.notifier)
                              .setMode(ThemeMode.light),
                        ),
                        const SizedBox(width: 8),
                        _ModeButton(
                          icon: Icons.dark_mode_rounded,
                          label: l10n.darkMode,
                          isSelected:
                              themeSettings.mode == ThemeMode.dark,
                          onTap: () => ref
                              .read(themeControllerProvider.notifier)
                              .setMode(ThemeMode.dark),
                        ),
                        const SizedBox(width: 8),
                        _ModeButton(
                          icon: Icons.auto_mode_rounded,
                          label: l10n.systemMode,
                          isSelected:
                              themeSettings.mode == ThemeMode.system,
                          onTap: () => ref
                              .read(themeControllerProvider.notifier)
                              .setMode(ThemeMode.system),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Color Palette ────────────────────────────────────────────
              ParentCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ParentSectionHeader(title: l10n.themePalette),
                    const SizedBox(height: 12),
                    ...ThemePalettes.all.map((palette) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _PaletteRow(
                            palette: palette,
                            isSelected:
                                themeSettings.paletteId == palette.id,
                            onTap: () => ref
                                .read(themeControllerProvider.notifier)
                                .setPalette(palette.id),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MODE BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? ParentColors.parentGreen.withValues(alpha: 0.12)
                : colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? ParentColors.parentGreen
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected
                    ? ParentColors.parentGreen
                    : colors.onSurfaceVariant,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? ParentColors.parentGreen
                      : colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PALETTE ROW
// ─────────────────────────────────────────────────────────────────────────────

class _PaletteRow extends StatelessWidget {
  final ThemePalette palette;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaletteRow({
    required this.palette,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? ParentColors.parentGreen.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? ParentColors.parentGreen
                : colors.outlineVariant.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: palette.seedColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: palette.seedColor.withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                palette.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? ParentColors.parentGreen
                      : colors.onSurface,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  size: 20, color: ParentColors.parentGreen),
          ],
        ),
      ),
    );
  }
}
