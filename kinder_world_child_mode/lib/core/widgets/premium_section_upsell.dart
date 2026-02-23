import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kinder_world/core/localization/app_localizations.dart';
import 'package:kinder_world/core/widgets/premium_badge.dart';

class PremiumSectionUpsell extends StatelessWidget {
  final String title;
  final String description;
  final String? buttonLabel;
  final bool showBadge;
  final EdgeInsetsGeometry padding;

  const PremiumSectionUpsell({
    super.key,
    required this.title,
    required this.description,
    this.buttonLabel,
    this.showBadge = true,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style:
                      textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              if (showBadge) const PremiumBadge(),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.push('/parent/subscription'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primary,
                side: BorderSide(color: colors.primary),
              ),
              child: Text(buttonLabel ?? l10n?.upgradeNow ?? 'Upgrade'),
            ),
          ),
        ],
      ),
    );
  }
}
