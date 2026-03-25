import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kinder_world/core/localization/app_localizations.dart';
import 'package:kinder_world/core/navigation/app_navigation_controller.dart';
import 'package:kinder_world/core/providers/plan_provider.dart';
import 'package:kinder_world/core/providers/subscription_provider.dart';
import 'package:kinder_world/core/services/subscription_service.dart';
import 'package:kinder_world/core/subscription/plan_info.dart';
import 'package:kinder_world/core/subscription/subscription_return.dart';
import 'package:kinder_world/core/theme/theme_extensions.dart';
import 'package:kinder_world/core/widgets/parent_design_system.dart';
import 'package:kinder_world/router.dart';
import 'package:kinder_world/features/parent_mode/subscription/subscription_plan_catalog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kinder_world/core/utils/color_compat.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({
    super.key,
    this.returnPayload,
  });

  final SubscriptionReturnPayload? returnPayload;

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen>
    with WidgetsBindingObserver {
  bool _isProcessing = false;
  String? _actionKey;
  bool _refreshOnResume = false;
  String? _pendingSessionId;
  PlanTier? _pendingTier;
  String? _pendingReturnFlow;
  SubscriptionReturnPayload? _returnPayload;
  bool _handledReturnPayload = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _returnPayload = widget.returnPayload;
    if (_returnPayload != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _processReturnPayload(_returnPayload!);
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SubscriptionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.returnPayload?.cacheKey != oldWidget.returnPayload?.cacheKey) {
      _returnPayload = widget.returnPayload;
      _handledReturnPayload = false;
      if (_returnPayload != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _processReturnPayload(_returnPayload!);
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _refreshOnResume) {
      _refreshOnResume = false;
      _handleExternalReturn();
    }
    super.didChangeAppLifecycleState(state);
  }

  String _planTitle(PlanTier tier, AppLocalizations l10n) {
    switch (tier) {
      case PlanTier.free:
        return l10n.basicFeaturesOnly;
      case PlanTier.premium:
        return l10n.planPremium;
      case PlanTier.familyPlus:
        return l10n.bestForFamilies;
    }
  }

  Future<void> _refreshSubscriptionData() async {
    ref.invalidate(subscriptionSnapshotProvider);
    ref.invalidate(subscriptionHistoryProvider);
    await ref.read(subscriptionSnapshotProvider.future);
    try {
      await ref.read(subscriptionHistoryProvider.future);
    } catch (_) {
      // Keep the main screen usable even if history refresh fails.
    }
  }

  Future<void> _handleExternalReturn() async {
    await _refreshSubscriptionData();
    if (mounted) {
      setState(() {
        _returnPayload ??= SubscriptionReturnPayload(
          flow: _pendingReturnFlow ?? 'checkout',
          result: 'pending',
        );
        _pendingReturnFlow = null;
      });
    }
  }

  Future<void> _processReturnPayload(SubscriptionReturnPayload payload) async {
    if (_handledReturnPayload) return;
    _handledReturnPayload = true;

    final service = ref.read(subscriptionServiceProvider);
    final resolvedSessionId = payload.sessionId ?? _pendingSessionId;
    if (payload.indicatesSuccessfulCheckout &&
        resolvedSessionId != null &&
        resolvedSessionId.isNotEmpty) {
      SubscriptionSnapshot? snapshot;
      try {
        snapshot = await ref.read(subscriptionSnapshotProvider.future);
      } catch (_) {
        snapshot = null;
      }
      final planId =
          snapshot?.lifecycle.selectedPlanId ?? snapshot?.currentPlanId;
      final tier = (planId != null && planId.isNotEmpty)
          ? subscriptionPlanTierFromBackend(planId)
          : (_pendingTier ?? PlanTier.free);
      if (tier != PlanTier.free) {
        try {
          await service.activatePlan(tier, sessionId: resolvedSessionId);
        } catch (_) {
          // Allow webhook to update state; still refresh snapshot below.
        }
      }
    }
    await _refreshSubscriptionData();
  }

  Future<void> _runSubscriptionAction({
    required String actionKey,
    required Future<Map<String, dynamic>> Function(SubscriptionService service)
        action,
    required String successMessage,
  }) async {
    if (_isProcessing) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _isProcessing = true;
      _actionKey = actionKey;
    });

    try {
      final service = ref.read(subscriptionServiceProvider);
      await action(service);
      await _refreshSubscriptionData();
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (e) {
      await _refreshSubscriptionData();
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(_resolveActionError(e))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _actionKey = null;
        });
      }
    }
  }

  Future<void> _startCheckout(PlanTier tier) async {
    if (_isProcessing) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _isProcessing = true;
      _actionKey = 'checkout_${tier.name}';
    });

    try {
      final service = ref.read(subscriptionServiceProvider);
      final session = await service.startCheckout(tier);
      final uri = Uri.tryParse(session.checkoutUrl);
      if (uri == null) {
        throw StateError(l10n.subscriptionInvalidCheckoutUrl);
      }

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw StateError(l10n.subscriptionUnableToLaunchCheckout);
      }

      setState(() {
        _pendingSessionId = session.sessionId;
        _pendingTier = tier;
        _pendingReturnFlow = 'checkout';
        _refreshOnResume = true;
      });
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(_resolveActionError(e))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _actionKey = null;
        });
      }
    }
  }

  Future<void> _selectPlan(PlanTier tier) async {
    final l10n = AppLocalizations.of(context)!;
    if (tier == PlanTier.free) {
      await _runSubscriptionAction(
        actionKey: 'select_${tier.name}',
        action: (service) => service.activatePlan(tier),
        successMessage: l10n.planActivated(_planTitle(tier, l10n)),
      );
    } else {
      await _startCheckout(tier);
    }
  }

  Future<void> _cancelSubscription() async {
    final l10n = AppLocalizations.of(context)!;
    await _runSubscriptionAction(
      actionKey: 'cancel',
      action: (service) => service.cancelCurrentSubscription(),
      successMessage: l10n.planActivated(_planTitle(PlanTier.free, l10n)),
    );
  }

  Future<void> _manageSubscription() async {
    if (_isProcessing) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _isProcessing = true;
      _actionKey = 'manage';
    });

    try {
      final service = ref.read(subscriptionServiceProvider);
      final url = await service.manageCurrentSubscription();
      final uri = Uri.tryParse(url);
      if (uri == null) {
        throw StateError(l10n.subscriptionInvalidPortalUrl);
      }
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw StateError(l10n.subscriptionUnableToOpenPortal);
      }
      setState(() {
        _pendingReturnFlow = 'portal';
        _refreshOnResume = true;
      });
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(_resolveActionError(e))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _actionKey = null;
        });
      }
    }
  }

  String _resolveActionError(Object error) {
    final l10n = AppLocalizations.of(context)!;
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['detail'] != null) {
        return data['detail'].toString();
      }
      if (data is String && data.isNotEmpty) {
        return data;
      }
      if (error.message != null && error.message!.trim().isNotEmpty) {
        return error.message!.trim();
      }
    }
    return l10n.tryAgain;
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return '-';
    return DateFormat('MMM d, y \u2022 h:mm a').format(value);
  }

  String _formatAmount(int amountCents, String currency) {
    final amount = amountCents / 100;
    return '${amount.toStringAsFixed(2)} ${currency.toUpperCase()}';
  }

  String _displayStatus(BuildContext context, String raw) {
    return AppLocalizations.of(context)!.subscriptionStatusLabel(raw);
  }

  Color _statusColor(BuildContext context, String rawStatus) {
    final colors = Theme.of(context).colorScheme;
    switch (rawStatus) {
      case 'active':
        return colors.primary;
      case 'canceled':
      case 'failed':
      case 'past_due':
        return colors.error;
      case 'pending_activation':
        return colors.tertiary;
      default:
        return colors.onSurfaceVariant;
    }
  }

  Widget? _buildPaymentStatusBanner(SubscriptionLifecycle lifecycle) {
    final l10n = AppLocalizations.of(context)!;
    final status = lifecycle.lastPaymentStatus.toLowerCase();
    if (status == 'not_applicable') return null;
    final colors = Theme.of(context).colorScheme;
    IconData icon = Icons.payments_outlined;
    Color bg = colors.surfaceContainerHighest;
    Color fg = colors.onSurface;
    String label = l10n.subscriptionPaymentStatus(
      _displayStatus(context, status),
    );

    if (status.contains('pending')) {
      icon = Icons.schedule_rounded;
      bg = colors.tertiaryContainer;
      fg = colors.onTertiaryContainer;
    } else if (status.contains('action')) {
      icon = Icons.warning_amber_rounded;
      bg = colors.secondaryContainer;
      fg = colors.onSecondaryContainer;
    } else if (status.contains('failed') || status.contains('canceled')) {
      icon = Icons.error_outline_rounded;
      bg = colors.errorContainer;
      fg = colors.onErrorContainer;
    } else if (status.contains('refunded')) {
      icon = Icons.undo_rounded;
      bg = colors.secondaryContainer;
      fg = colors.onSecondaryContainer;
    } else if (status.contains('succeeded') || status.contains('paid')) {
      icon = Icons.check_circle_rounded;
      bg = colors.secondaryContainer;
      fg = colors.onSecondaryContainer;
    }

    return ParentCard(
      backgroundColor: bg,
      child: Row(
        children: [
          Icon(icon, color: fg),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Text(
            lifecycle.provider.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }

  Widget? _buildProviderStateBanner({
    required SubscriptionSnapshot snapshot,
    SubscriptionHistorySnapshot? history,
  }) {
    final events = history?.events ?? snapshot.recentEvents;
    final attempts = history?.paymentAttempts ?? snapshot.paymentAttempts;
    final transactions =
        history?.billingTransactions ?? snapshot.billingHistory;
    final lifecycle = snapshot.lifecycle;

    bool hasPortalUnavailable = events.any((event) {
      final details = event.details;
      final operation = details['operation']?.toString();
      final code = details['code']?.toString();
      return event.eventType == 'failure' &&
          operation == 'billing_portal' &&
          (code == 'BILLING_PORTAL_NOT_CONFIGURED' ||
              code == 'PROVIDER_UNAVAILABLE');
    });

    bool hasProviderUnavailable = events.any((event) {
      final code = event.details['code']?.toString();
      return code == 'PROVIDER_UNAVAILABLE' ||
          event.eventType == 'checkout_failed' ||
          event.eventType == 'activation_failed';
    });

    bool hasActionRequired = lifecycle.lastPaymentStatus == 'action_required' ||
        attempts.any((item) => item.status == 'action_required');

    bool hasFailed = lifecycle.lastPaymentStatus == 'failed' ||
        attempts.any((item) => item.status == 'failed') ||
        events.any((event) =>
            event.eventType == 'failure' ||
            event.eventType == 'activation_failed' ||
            event.eventType == 'checkout_failed' ||
            event.eventType == 'refund_failed');

    bool hasRefunded = transactions.any((item) =>
        item.transactionType == 'refund' || item.status == 'refunded');

    bool hasCanceled = lifecycle.status == 'canceled' ||
        lifecycle.lastPaymentStatus == 'canceled';

    bool hasPending = lifecycle.status == 'pending_activation' ||
        lifecycle.lastPaymentStatus == 'pending' ||
        attempts.any((item) => item.status == 'pending');

    if (!(hasPortalUnavailable ||
        hasProviderUnavailable ||
        hasActionRequired ||
        hasFailed ||
        hasRefunded ||
        hasCanceled ||
        hasPending)) {
      return null;
    }

    final colors = Theme.of(context).colorScheme;
    IconData icon = Icons.info_outline_rounded;
    Color bg = colors.surfaceContainerHighest;
    Color fg = colors.onSurface;
    final l10n = AppLocalizations.of(context)!;
    String title = l10n.subscriptionProviderSyncTitle;
    String subtitle = l10n.subscriptionProviderSyncSubtitle;

    if (hasPortalUnavailable) {
      icon = Icons.link_off_rounded;
      bg = colors.tertiaryContainer;
      fg = colors.onTertiaryContainer;
      title = l10n.subscriptionPortalUnavailableTitle;
      subtitle = l10n.subscriptionPortalUnavailableSubtitle;
    } else if (hasProviderUnavailable) {
      icon = Icons.cloud_off_rounded;
      bg = colors.tertiaryContainer;
      fg = colors.onTertiaryContainer;
      title = l10n.subscriptionProviderUnavailableTitle;
      subtitle = l10n.subscriptionProviderUnavailableSubtitle;
    } else if (hasActionRequired) {
      icon = Icons.warning_amber_rounded;
      bg = colors.secondaryContainer;
      fg = colors.onSecondaryContainer;
      title = l10n.subscriptionActionRequiredTitle;
      subtitle = l10n.subscriptionActionRequiredSubtitle;
    } else if (hasFailed) {
      icon = Icons.error_outline_rounded;
      bg = colors.errorContainer;
      fg = colors.onErrorContainer;
      title = l10n.subscriptionPaymentFailedTitle;
      subtitle = l10n.subscriptionPaymentFailedSubtitle;
    } else if (hasRefunded) {
      icon = Icons.undo_rounded;
      bg = colors.secondaryContainer;
      fg = colors.onSecondaryContainer;
      title = l10n.subscriptionPaymentRefundedTitle;
      subtitle = l10n.subscriptionPaymentRefundedSubtitle;
    } else if (hasCanceled) {
      icon = Icons.close_rounded;
      bg = colors.surfaceContainerHighest;
      fg = colors.onSurface;
      title = l10n.subscriptionCanceledTitle;
      subtitle = l10n.subscriptionCanceledSubtitle;
    } else if (hasPending) {
      icon = Icons.schedule_rounded;
      bg = colors.tertiaryContainer;
      fg = colors.onTertiaryContainer;
      title = l10n.subscriptionPaymentPendingTitle;
      subtitle = l10n.subscriptionPaymentPendingSubtitle;
    }

    return ParentCard(
      backgroundColor: bg,
      child: Row(
        children: [
          Icon(icon, color: fg),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: fg.withValuesCompat(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildReturnBanner(SubscriptionReturnPayload? payload) {
    if (payload == null) return null;
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    IconData icon = Icons.info_outline_rounded;
    Color bg = colors.surfaceContainerHighest;
    Color fg = colors.onSurface;
    String title = l10n.subscriptionProviderSyncTitle;
    String subtitle = l10n.subscriptionProviderSyncSubtitle;

    switch (payload.result) {
      case 'success':
        icon = Icons.check_circle_rounded;
        bg = colors.secondaryContainer;
        fg = colors.onSecondaryContainer;
        title = l10n.subscriptionReturnSuccessTitle;
        subtitle = l10n.subscriptionReturnSuccessSubtitle;
        break;
      case 'canceled':
        icon = Icons.close_rounded;
        bg = colors.surfaceContainerHighest;
        fg = colors.onSurface;
        title = l10n.subscriptionReturnCanceledTitle;
        subtitle = l10n.subscriptionReturnCanceledSubtitle;
        break;
      case 'failed':
        icon = Icons.error_outline_rounded;
        bg = colors.errorContainer;
        fg = colors.onErrorContainer;
        title = l10n.subscriptionPaymentFailedTitle;
        subtitle = l10n.subscriptionPaymentFailedSubtitle;
        break;
      case 'pending':
      default:
        icon = Icons.schedule_rounded;
        bg = colors.tertiaryContainer;
        fg = colors.onTertiaryContainer;
        title = payload.flow == 'portal'
            ? l10n.subscriptionReturnPortalTitle
            : l10n.subscriptionReturnPendingTitle;
        subtitle = payload.flow == 'portal'
            ? l10n.subscriptionReturnPortalSubtitle
            : l10n.subscriptionReturnPendingSubtitle;
        break;
    }

    return ParentCard(
      backgroundColor: bg,
      child: Row(
        children: [
          Icon(icon, color: fg),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: fg.withValuesCompat(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final snapshotAsync = ref.watch(subscriptionSnapshotProvider);
    final historyAsync = ref.watch(subscriptionHistoryProvider);

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: AppBackButton(
          fallback: Routes.parentDashboard,
          color: colors.onSurface,
        ),
        title: Text(
          l10n.subscriptionTitle,
          style: textTheme.titleMedium?.copyWith(
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
            color: colors.outlineVariant.withValuesCompat(alpha: 0.4),
          ),
        ),
      ),
      body: SafeArea(
        child: snapshotAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: colors.primary),
          ),
          error: (_, __) => _SubscriptionStateCard(
            icon: Icons.cloud_off_rounded,
            title: l10n.error,
            subtitle: l10n.tryAgain,
            buttonLabel: l10n.retry,
            onPressed: () {
              ref.invalidate(subscriptionSnapshotProvider);
              ref.invalidate(subscriptionHistoryProvider);
            },
          ),
          data: (snapshot) {
            final history = historyAsync.valueOrNull;
            final lifecycle = snapshot.lifecycle;
            final plan = snapshot.planInfo;
            final parent = context.parentTheme;
            final isPremium = lifecycle.hasPaidAccess;
            final paymentBanner = _buildPaymentStatusBanner(lifecycle);
            final returnBanner = _buildReturnBanner(_returnPayload);
            final providerBanner = _buildProviderStateBanner(
              snapshot: snapshot,
              history: history,
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (returnBanner != null) ...[
                    returnBanner,
                    const SizedBox(height: 16),
                  ],
                  if (providerBanner != null) ...[
                    providerBanner,
                    const SizedBox(height: 16),
                  ],
                  if (paymentBanner != null) ...[
                    paymentBanner,
                    const SizedBox(height: 16),
                  ],
                  ParentCard(
                    backgroundColor: colors.surfaceContainerHighest,
                    child: Row(
                      children: [
                        Icon(Icons.cloud_done_rounded, color: colors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.subscriptionBackendSyncNotice,
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ParentCard(
                    backgroundColor: isPremium
                        ? parent.rewardLight
                        : colors.surfaceContainerHighest,
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: (isPremium
                                    ? parent.reward
                                    : colors.onSurfaceVariant)
                                .withValuesCompat(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            isPremium
                                ? Icons.workspace_premium_rounded
                                : Icons.lock_open_rounded,
                            size: 26,
                            color: isPremium
                                ? parent.reward
                                : colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _planTitle(plan.tier, l10n),
                                style: textTheme.titleSmall?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: colors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${l10n.subscriptionLifecycleStatus}: ${_displayStatus(context, lifecycle.status)}',
                                style: textTheme.bodySmall?.copyWith(
                                  fontSize: 13,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                '${l10n.subscriptionLifecycleLastPaymentStatus}: ${_displayStatus(context, lifecycle.lastPaymentStatus)}',
                                style: textTheme.bodySmall?.copyWith(
                                  fontSize: 13,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _StatusChip(
                          label: _displayStatus(context, lifecycle.status),
                          color: _statusColor(context, lifecycle.status),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ParentCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ParentSectionHeader(
                          title: l10n.subscriptionLifecycleTitle,
                        ),
                        const SizedBox(height: 12),
                        _LifecycleRow(
                          label: l10n.subscriptionLifecycleCurrentPlan,
                          value: snapshot.currentPlanId,
                        ),
                        _LifecycleRow(
                          label: l10n.subscriptionLifecycleStatus,
                          value: _displayStatus(context, lifecycle.status),
                        ),
                        _LifecycleRow(
                          label: l10n.subscriptionLifecycleStartedAt,
                          value: _formatDateTime(lifecycle.startedAt),
                        ),
                        _LifecycleRow(
                          label: l10n.subscriptionLifecycleExpiresAt,
                          value: _formatDateTime(lifecycle.expiresAt),
                        ),
                        _LifecycleRow(
                          label: l10n.subscriptionLifecycleCancelAt,
                          value: _formatDateTime(lifecycle.cancelAt),
                        ),
                        _LifecycleRow(
                          label: l10n.subscriptionLifecycleWillRenew,
                          value: lifecycle.willRenew
                              ? l10n.yesLabel
                              : l10n.noLabel,
                        ),
                        _LifecycleRow(
                          label: l10n.subscriptionLifecycleLastPaymentStatus,
                          value: _displayStatus(
                            context,
                            lifecycle.lastPaymentStatus,
                          ),
                        ),
                        _LifecycleRow(
                          label: l10n.subscriptionLifecycleProvider,
                          value: lifecycle.provider,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ParentCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ParentSectionHeader(
                          title: l10n.subscriptionHistorySummaryTitle,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _SummaryChip(
                              icon: Icons.timeline_rounded,
                              label: l10n.subscriptionEventsTitle,
                              value: '${snapshot.historySummary.eventCount}',
                            ),
                            _SummaryChip(
                              icon: Icons.receipt_long_rounded,
                              label: l10n.subscriptionBillingHistoryTitle,
                              value:
                                  '${snapshot.historySummary.billingTransactionCount}',
                            ),
                            _SummaryChip(
                              icon: Icons.credit_card_rounded,
                              label: l10n.subscriptionPaymentAttemptsTitle,
                              value:
                                  '${snapshot.historySummary.paymentAttemptCount}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isPremium)
                    ParentCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed:
                                  _isProcessing ? null : _manageSubscription,
                              child: _ActionLabel(
                                isBusy: _isProcessing && _actionKey == 'manage',
                                label: l10n.manageSubscription,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed:
                                  _isProcessing ? null : _cancelSubscription,
                              child: _ActionLabel(
                                isBusy: _isProcessing && _actionKey == 'cancel',
                                label: l10n.cancel,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (isPremium) const SizedBox(height: 20),
                  ParentCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ParentSectionHeader(title: l10n.yourPlanIncludes),
                        const SizedBox(height: 16),
                        _buildFeatureRow(
                          Icons.people_rounded,
                          plan.isUnlimitedChildren
                              ? l10n.planUnlimitedChildren
                              : l10n.planChildProfiles(plan.maxChildren),
                          parent.primary,
                        ),
                        _buildFeatureRow(
                          Icons.bar_chart_rounded,
                          plan.hasAdvancedReports
                              ? l10n.advancedReportsLabel
                              : l10n.planBasicReports,
                          colors.tertiary,
                        ),
                        _buildFeatureRow(
                          Icons.psychology_rounded,
                          plan.hasAiInsights
                              ? l10n.aiInsights
                              : l10n.planFeatureInPremium,
                          parent.success,
                        ),
                        _buildFeatureRow(
                          Icons.download_rounded,
                          plan.hasOfflineDownloads
                              ? l10n.offlineDownloadsLabel
                              : l10n.planFeatureInPremium,
                          parent.warning,
                        ),
                        _buildFeatureRow(
                          Icons.support_agent_rounded,
                          plan.tier == PlanTier.familyPlus
                              ? l10n.prioritySupportLabel
                              : l10n.manageSubscription,
                          parent.reward,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _HistorySectionCard(
                    title: l10n.subscriptionEventsTitle,
                    icon: Icons.event_note_rounded,
                    loading: historyAsync.isLoading,
                    errorMessage: historyAsync.hasError
                        ? historyAsync.error.toString()
                        : null,
                    children: (history?.events ?? snapshot.recentEvents)
                        .take(8)
                        .map((event) => _HistoryTile(
                              title:
                                  '${_displayStatus(context, event.eventType)} \u2022 ${event.planId}',
                              subtitle:
                                  '${_displayStatus(context, event.status)} \u2022 ${event.source}',
                              trailing: _formatDateTime(event.occurredAt),
                              icon: Icons.timeline_rounded,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  _HistorySectionCard(
                    title: l10n.subscriptionBillingHistoryTitle,
                    icon: Icons.receipt_long_rounded,
                    loading: historyAsync.isLoading,
                    errorMessage: historyAsync.hasError
                        ? historyAsync.error.toString()
                        : null,
                    children: (history?.billingTransactions ??
                            snapshot.billingHistory)
                        .take(8)
                        .map((transaction) => _HistoryTile(
                              title:
                                  '${_displayStatus(context, transaction.transactionType)} \u2022 ${transaction.planId}',
                              subtitle:
                                  '${_formatAmount(transaction.amountCents, transaction.currency)} \u2022 ${_displayStatus(context, transaction.status)}',
                              trailing:
                                  _formatDateTime(transaction.effectiveAt),
                              icon: Icons.receipt_rounded,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  _HistorySectionCard(
                    title: l10n.subscriptionPaymentAttemptsTitle,
                    icon: Icons.credit_score_rounded,
                    loading: historyAsync.isLoading,
                    errorMessage: historyAsync.hasError
                        ? historyAsync.error.toString()
                        : null,
                    children:
                        (history?.paymentAttempts ?? snapshot.paymentAttempts)
                            .take(8)
                            .map((attempt) => _HistoryTile(
                                  title:
                                      '${_displayStatus(context, attempt.attemptType)} \u2022 ${attempt.planId}',
                                  subtitle: [
                                    _formatAmount(
                                        attempt.amountCents, attempt.currency),
                                    _displayStatus(context, attempt.status),
                                    if (attempt.failureCode != null &&
                                        attempt.failureCode!.isNotEmpty)
                                      attempt.failureCode!,
                                  ].join(' \u2022 '),
                                  trailing: _formatDateTime(
                                    attempt.completedAt ?? attempt.requestedAt,
                                  ),
                                  icon: Icons.payments_outlined,
                                ))
                            .toList(),
                  ),
                  const SizedBox(height: 20),
                  ParentSectionHeader(title: l10n.availablePlans),
                  const SizedBox(height: 12),
                  ...buildSubscriptionPlanCardConfigs(l10n)
                      .asMap()
                      .entries
                      .map((entry) {
                    final index = entry.key;
                    final config = entry.value;
                    final accentColor = config.tier == PlanTier.familyPlus
                        ? parent.primary
                        : parent.info;
                    return Padding(
                      padding: EdgeInsets.only(bottom: index == 1 ? 0 : 12),
                      child: _buildPlanCard(
                        currentPlanId: snapshot.currentPlanId,
                        title: config.title,
                        price: config.price,
                        priceLabel: config.priceLabel,
                        subtitle: config.subtitle,
                        features: config.features,
                        tier: config.tier,
                        isRecommended: config.isRecommended,
                        accentColor: accentColor,
                        l10n: l10n,
                      ),
                    );
                  }),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text, Color color) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValuesCompat(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String currentPlanId,
    required String title,
    required String price,
    required String priceLabel,
    required String subtitle,
    required List<String> features,
    required PlanTier tier,
    required Color accentColor,
    required AppLocalizations l10n,
    bool isRecommended = false,
  }) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isCurrent = subscriptionPlanTierFromBackend(currentPlanId) == tier;
    final actionKey = 'select_${tier.name}';
    final isProcessingThis = _actionKey == actionKey;
    final buttonForeground = isCurrent ? colors.onSurface : accentColor.onColor;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRecommended
              ? accentColor
              : colors.outlineVariant.withValuesCompat(alpha: 0.6),
          width: isRecommended ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow
                .withValuesCompat(alpha: isRecommended ? 0.10 : 0.05),
            blurRadius: isRecommended ? 18 : 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isRecommended)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.recommendedLabel.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: accentColor.onColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            if (isRecommended) const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleMedium?.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: textTheme.headlineSmall?.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: accentColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      priceLabel,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: accentColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 13,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed:
                    isCurrent || _isProcessing ? null : () => _selectPlan(tier),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      isCurrent ? colors.surfaceContainerHighest : accentColor,
                  foregroundColor: buttonForeground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _ActionLabel(
                  isBusy: _isProcessing && isProcessingThis,
                  label:
                      isCurrent ? l10n.currentPlanLabel : l10n.choosePlanLabel,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionStateCard extends StatelessWidget {
  const _SubscriptionStateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 30, color: colors.primary),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onPressed,
                child: Text(buttonLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LifecycleRow extends StatelessWidget {
  const _LifecycleRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: colors.outlineVariant.withValuesCompat(alpha: 0.35),
                ),
              ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.primary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _HistorySectionCard extends StatelessWidget {
  const _HistorySectionCard({
    required this.title,
    required this.icon,
    required this.loading,
    required this.errorMessage,
    required this.children,
  });

  final String title;
  final IconData icon;
  final bool loading;
  final String? errorMessage;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ParentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(),
              ),
            )
          else if (errorMessage != null)
            Text(
              errorMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.error,
                  ),
            )
          else if (children.isEmpty)
            Text(
              AppLocalizations.of(context)!.subscriptionNoHistoryYet,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            )
          else
            Column(children: children),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String trailing;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colors.primary.withValuesCompat(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              trailing,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValuesCompat(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _ActionLabel extends StatelessWidget {
  const _ActionLabel({
    required this.isBusy,
    required this.label,
  });

  final bool isBusy;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (!isBusy) {
      return Text(label);
    }
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2.2,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}
