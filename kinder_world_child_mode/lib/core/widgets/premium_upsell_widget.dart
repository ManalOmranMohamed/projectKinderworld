import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kinder_world/core/constants/app_constants.dart';
import 'package:kinder_world/core/localization/app_localizations.dart';
import 'package:kinder_world/core/subscription/plan_info.dart';

class PremiumUpsellWidget extends StatelessWidget {
  final PlanInfo plan;
  final PlanTier requiredTier;
  final String? featureLabel;
  final EdgeInsetsGeometry padding;
  final bool compact;
  final VoidCallback? onUpgrade;

  const PremiumUpsellWidget({
    super.key,
    required this.plan,
    required this.requiredTier,
    this.featureLabel,
    this.padding = const EdgeInsets.all(20),
    this.compact = false,
    this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final ctaLabel =
        requiredTier == PlanTier.familyPlus ? l10n.choosePlan : l10n.upgradeNow;

    final effectiveOnUpgrade =
        onUpgrade ?? () => context.push('/parent/subscription');

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: compact
          ? _CompactUpsell(
              l10n: l10n,
              colors: colors,
              ctaLabel: ctaLabel,
              featureLabel: featureLabel,
              onUpgrade: effectiveOnUpgrade,
            )
          : _FullUpsell(
              l10n: l10n,
              colors: colors,
              plan: plan,
              requiredTier: requiredTier,
              featureLabel: featureLabel,
              ctaLabel: ctaLabel,
              onUpgrade: effectiveOnUpgrade,
            ),
    );
  }
}

class _CompactUpsell extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme colors;
  final String ctaLabel;
  final String? featureLabel;
  final VoidCallback onUpgrade;

  const _CompactUpsell({
    required this.l10n,
    required this.colors,
    required this.ctaLabel,
    required this.featureLabel,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.lock, color: colors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.planFeatureInPremium,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (featureLabel != null && featureLabel!.isNotEmpty)
                    Text(
                      featureLabel!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: onUpgrade,
            child: Text(
              ctaLabel,
              style: const TextStyle(
                fontSize: AppConstants.fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FullUpsell extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme colors;
  final PlanInfo plan;
  final PlanTier requiredTier;
  final String? featureLabel;
  final String ctaLabel;
  final VoidCallback onUpgrade;

  const _FullUpsell({
    required this.l10n,
    required this.colors,
    required this.plan,
    required this.requiredTier,
    required this.featureLabel,
    required this.ctaLabel,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final featureList = _featureList(l10n, requiredTier);
    final planName = _planName(l10n, plan.tier);
    final planDetails = _planDetails(l10n, plan);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.lock, color: colors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.planFeatureInPremium,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (featureLabel != null && featureLabel!.isNotEmpty)
                    Text(
                      featureLabel!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.currentPlan,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      planName,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: planDetails
                          .map((detail) => _DetailChip(label: detail))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.premiumFeatures,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        ...featureList.map(
          (feature) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 18, color: colors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feature,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: onUpgrade,
            child: Text(
              ctaLabel,
              style: const TextStyle(
                fontSize: AppConstants.fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<String> _featureList(AppLocalizations l10n, PlanTier tier) {
    switch (tier) {
      case PlanTier.familyPlus:
        return [
          l10n.planAiInsightsPro,
          l10n.planAdvancedReports,
          l10n.planOfflineDownloads,
          l10n.planSmartControls,
          l10n.planExclusiveContent,
          l10n.planFamilyDashboard,
          l10n.planUnlimitedChildren,
        ];
      case PlanTier.premium:
        return [
          l10n.planAiInsightsPro,
          l10n.planAdvancedReports,
          l10n.planOfflineDownloads,
          l10n.planSmartControls,
          l10n.planExclusiveContent,
        ];
      case PlanTier.free:
        return [
          l10n.planBasicReports,
        ];
    }
  }

  String _planName(AppLocalizations l10n, PlanTier tier) {
    switch (tier) {
      case PlanTier.free:
        return l10n.planFree;
      case PlanTier.premium:
        return l10n.planPremium;
      case PlanTier.familyPlus:
        return l10n.planFamilyPlus;
    }
  }

  List<String> _planDetails(AppLocalizations l10n, PlanInfo plan) {
    final details = <String>[
      plan.isUnlimitedChildren
          ? l10n.planUnlimitedChildren
          : l10n.planChildLimit(plan.maxChildren),
      plan.hasAdvancedReports ? l10n.planAdvancedReports : l10n.planBasicReports,
    ];
    if (plan.hasAiInsights) {
      details.add(l10n.planAiInsightsPro);
    }
    if (plan.hasFamilyDashboard) {
      details.add(l10n.planFamilyDashboard);
    }
    return details;
  }
}

class _DetailChip extends StatelessWidget {
  final String label;

  const _DetailChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
      ),
    );
  }
}
