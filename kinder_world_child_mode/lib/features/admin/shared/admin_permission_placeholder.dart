import 'package:flutter/material.dart';
import 'package:kinder_world/core/localization/app_localizations.dart';
import 'package:kinder_world/core/utils/color_compat.dart';

/// IMPORTANT:
/// All UI text must use AppLocalizations.
/// Hardcoded strings are NOT allowed.

class AdminPermissionPlaceholder extends StatelessWidget {
  const AdminPermissionPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer.withValuesCompat(alpha: 0.35),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.errorContainer),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, color: colorScheme.error, size: 40),
            const SizedBox(height: 16),
            Text(
              l10n.adminPermissionDenied,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.adminPermissionDeniedMessage,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
