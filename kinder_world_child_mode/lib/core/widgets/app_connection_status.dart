import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kinder_world/core/localization/app_localizations.dart';
import 'package:kinder_world/core/providers/sync_status_provider.dart';

enum AppConnectionStatusVariant { child, parent, admin }

class AppConnectionStatusBanner extends ConsumerWidget {
  const AppConnectionStatusBanner.child({super.key})
      : variant = AppConnectionStatusVariant.child;

  const AppConnectionStatusBanner.parent({super.key})
      : variant = AppConnectionStatusVariant.parent;

  const AppConnectionStatusBanner.admin({super.key})
      : variant = AppConnectionStatusVariant.admin;

  final AppConnectionStatusVariant variant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider);
    if (!status.isOffline && !status.isSyncing) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isOffline = status.isOffline;
    final accent = _accentColor(context);
    final background = isOffline
        ? colors.errorContainer.withValues(alpha: 0.88)
        : accent.withValues(alpha: 0.14);
    final foreground = isOffline ? colors.onErrorContainer : colors.onSurface;
    final subtitleColor = isOffline
        ? colors.onErrorContainer.withValues(alpha: 0.86)
        : colors.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isOffline
                ? colors.error.withValues(alpha: 0.18)
                : accent.withValues(alpha: 0.18),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isOffline
                    ? colors.onErrorContainer.withValues(alpha: 0.12)
                    : accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isOffline ? Icons.cloud_off_rounded : Icons.sync_rounded,
                color: isOffline ? colors.onErrorContainer : accent,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOffline ? l10n.offlineMode : l10n.syncInProgress,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (isOffline) ...[
                    const SizedBox(height: 2),
                    Text(
                      l10n.offlineSyncHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (status.isSyncing)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: accent,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _accentColor(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    switch (variant) {
      case AppConnectionStatusVariant.child:
        return colors.primary;
      case AppConnectionStatusVariant.parent:
        return colors.secondary;
      case AppConnectionStatusVariant.admin:
        return colors.tertiary;
    }
  }
}
