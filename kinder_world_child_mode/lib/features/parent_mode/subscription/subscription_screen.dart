import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kinder_world/core/constants/app_constants.dart';
import 'package:kinder_world/core/providers/auth_controller.dart';
import 'package:kinder_world/core/providers/plan_provider.dart';
import 'package:kinder_world/core/providers/subscription_provider.dart';
import 'package:kinder_world/core/subscription/plan_info.dart';
import 'package:kinder_world/core/widgets/themed_card.dart';
import 'package:kinder_world/features/child_mode/paywall/payment_methods_screen.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool _isProcessing = false;
  PlanTier? _processingTier;

  String _planTitle(PlanTier tier) {
    switch (tier) {
      case PlanTier.free:
        return 'Free Plan';
      case PlanTier.premium:
        return 'Premium Plan';
      case PlanTier.familyPlus:
        return 'Family Plan';
    }
  }

  Future<void> _applyPlan(PlanTier tier) async {
    await ref.read(authControllerProvider.notifier).applyPlanSelection(tier);
    ref.invalidate(planInfoProvider);
  }

  Future<void> _selectPlan({
    required PlanTier tier,
    required bool requiresPayment,
  }) async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
      _processingTier = tier;
    });
    final messenger = ScaffoldMessenger.of(context);

    try {
      if (requiresPayment) {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()),
        );
        if (!mounted) return;

        final activated = await ref
            .read(subscriptionServiceProvider)
            .activateSubscription(tier);
        if (!activated) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Failed to activate subscription.')),
          );
          return;
        }
      }

      await _applyPlan(tier);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('${_planTitle(tier)} activated.')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _processingTier = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final plan =
        ref.watch(planInfoProvider).asData?.value ?? PlanInfo.fromTier(PlanTier.free);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Subscription'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/parent/dashboard');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Current Plan
              ThemedCard(
                padding: const EdgeInsets.all(20),
                borderRadius: BorderRadius.circular(16),
                surfaceColor: colors.secondaryContainer,
                border: Border.all(color: colors.secondary),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: colors.secondary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.star,
                        size: 30,
                        color: colors.secondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _planTitle(plan.tier),
                            style: textTheme.titleMedium?.copyWith(
                              fontSize: AppConstants.fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Subscription Active',
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 14,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Active',
                        style: textTheme.labelSmall?.copyWith(
                          color: colors.onPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Features
              Text(
                'Your Plan Includes:',
                style: textTheme.titleMedium?.copyWith(
                  fontSize: AppConstants.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildFeatureItem(
                context,
                Icons.people,
                'Up to ${plan.maxChildren} child profiles',
              ),
              _buildFeatureItem(context, Icons.school, 'Unlimited activities'),
              _buildFeatureItem(context, Icons.bar_chart, 'Advanced reports'),
              _buildFeatureItem(context, Icons.psychology, 'AI insights'),
              _buildFeatureItem(context, Icons.download, 'Offline downloads'),
              _buildFeatureItem(context, Icons.support, 'Priority support'),
              
              const SizedBox(height: 32),
              
              // Available Plans
              Text(
                'Available Plans',
                style: textTheme.titleMedium?.copyWith(
                  fontSize: AppConstants.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildPlanCard(
                context,
                plan,
                'Free Plan',
                '\$0',
                'Basic features only',
                [
                  'Limited activities',
                  '1 child profile',
                  'Basic reports',
                ],
                PlanTier.free,
              ),
              const SizedBox(height: 16),
              
              _buildPlanCard(
                context,
                plan,
                'Family Plan',
                '\$9.99',
                'Best for families',
                [
                  'Unlimited activities',
                  'Up to 1 child',
                  'Advanced reports',
                  'AI insights',
                  'Offline downloads',
                  'Priority support',
                ],
                PlanTier.familyPlus,
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colors.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: colors.secondary),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: AppConstants.fontSize,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingRow(
    BuildContext context,
    String label,
    String value,
  ) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: AppConstants.fontSize,
                color: colors.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: AppConstants.fontSize,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    PlanInfo currentPlan,
    String title,
    String price,
    String subtitle,
    List<String> features,
    PlanTier tier,
  ) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isRecommended = tier == PlanTier.familyPlus;
    final isCurrent = currentPlan.tier == tier;
    return ThemedCard(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isRecommended ? colors.primary : colors.outlineVariant,
        width: isRecommended ? 2 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: colors.shadow.withValues(alpha: 0.08),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isRecommended)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'RECOMMENDED',
                style: textTheme.labelSmall?.copyWith(
                  color: colors.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (isRecommended) const SizedBox(height: 12),
          
          Row(
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontSize: AppConstants.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: textTheme.titleLarge?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          ...features.map((feature) => _buildFeatureText(context, feature)),
          
          const SizedBox(height: 20),
          
          ElevatedButton(
            onPressed: isCurrent || _isProcessing
                ? null
                : () => _selectPlan(
                      tier: tier,
                      requiresPayment: tier != PlanTier.free,
                    ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isRecommended
                  ? colors.primary
                  : colors.surfaceContainerHighest,
              foregroundColor:
                  isRecommended ? colors.onPrimary : colors.onSurface,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: Text(
              isCurrent
                  ? 'Current Plan'
                  : _processingTier == tier
                      ? 'Processing...'
                      : 'Choose Plan',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureText(BuildContext context, String text) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.check, size: 16, color: colors.primary),
          const SizedBox(width: 8),
          Text(
            text,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 14,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
