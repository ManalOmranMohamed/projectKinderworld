import 'package:flutter/material.dart';
import 'package:kinder_world/core/localization/app_localizations.dart';
import 'package:kinder_world/core/utils/color_compat.dart';

/// IMPORTANT:
/// All UI text must use AppLocalizations.
/// Hardcoded strings are NOT allowed.

class PremiumBadge extends StatelessWidget {
  final String? label;

  const PremiumBadge({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final text = label ?? l10n.planPremium;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.primary.withValuesCompat(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
