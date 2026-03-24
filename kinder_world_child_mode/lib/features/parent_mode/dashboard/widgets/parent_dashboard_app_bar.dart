import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kinder_world/core/localization/app_localizations.dart';
import 'package:kinder_world/core/providers/theme_provider.dart';
import 'package:kinder_world/core/widgets/dashboard_theme_switch.dart';

class ParentDashboardSliverAppBar extends ConsumerWidget {
  const ParentDashboardSliverAppBar({
    super.key,
    required this.greeting,
  });

  final String greeting;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SliverAppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      floating: true,
      titleSpacing: 16,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.parentDashboard,
            style: textTheme.titleLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          Text(
            greeting,
            style: TextStyle(
              fontSize: 12,
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: colors.onSurface,
          ),
          tooltip: l10n.notifications,
          onPressed: () => context.go('/parent/notifications'),
        ),
        IconButton(
          icon: Icon(
            Icons.settings_outlined,
            color: colors.onSurface,
          ),
          tooltip: l10n.settings,
          onPressed: () => context.go('/parent/settings'),
        ),
        Builder(
          builder: (context) {
            final themeMode = ref.watch(themeControllerProvider).mode;
            final isDark = themeMode.resolvesToDark(theme.brightness);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: DashboardThemeSwitch(
                value: isDark,
                onChanged: (isDark) {
                  ref.read(themeControllerProvider.notifier).setMode(
                        isDark ? ThemeMode.dark : ThemeMode.light,
                      );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
