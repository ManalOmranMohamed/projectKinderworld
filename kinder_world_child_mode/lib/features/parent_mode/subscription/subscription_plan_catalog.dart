import 'package:kinder_world/core/localization/app_localizations.dart';
import 'package:kinder_world/core/subscription/plan_info.dart';

class SubscriptionPlanCardConfig {
  const SubscriptionPlanCardConfig({
    required this.title,
    required this.price,
    required this.priceLabel,
    required this.subtitle,
    required this.features,
    required this.tier,
    this.isRecommended = false,
  });

  final String title;
  final String price;
  final String priceLabel;
  final String subtitle;
  final List<String> features;
  final PlanTier tier;
  final bool isRecommended;
}

List<SubscriptionPlanCardConfig> buildSubscriptionPlanCardConfigs(
  AppLocalizations l10n,
) {
  final paidAccessLabel =
      '${l10n.oneTimePurchaseLabel} • ${l10n.lifetimeAccessLabel}';
  return [
    SubscriptionPlanCardConfig(
      title: l10n.planPremium,
      price: '\$39',
      priceLabel: paidAccessLabel,
      subtitle: l10n.planPremiumSubtitle,
      features: [
        l10n.unlimitedActivities,
        l10n.upToThreeChildren,
        '${l10n.advancedReportsLabel} & ${l10n.aiInsights}',
        l10n.offlineDownloadsLabel,
      ],
      tier: PlanTier.premium,
    ),
    SubscriptionPlanCardConfig(
      title: l10n.planFamilyPlus,
      price: '\$69',
      priceLabel: paidAccessLabel,
      subtitle: l10n.planFamilyPlusSubtitle,
      features: [
        l10n.unlimitedActivities,
        l10n.planUnlimitedChildren,
        '${l10n.advancedReportsLabel} & ${l10n.aiInsights}',
        l10n.offlineDownloadsLabel,
        l10n.planFamilyDashboard,
        l10n.prioritySupportLabel,
      ],
      tier: PlanTier.familyPlus,
      isRecommended: true,
    ),
  ];
}
