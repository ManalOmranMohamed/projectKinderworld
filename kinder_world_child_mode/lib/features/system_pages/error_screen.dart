import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kinder_world/core/constants/app_constants.dart';
import 'package:kinder_world/core/localization/app_localizations.dart';
import 'package:kinder_world/core/navigation/app_navigation_controller.dart';
import 'package:kinder_world/core/theme/theme_extensions.dart';
import 'package:kinder_world/features/system_pages/widgets/system_page_layout.dart';
import 'package:kinder_world/router.dart';

class ErrorScreen extends ConsumerStatefulWidget {
  final String error;

  const ErrorScreen({
    super.key,
    required this.error,
  });

  @override
  ConsumerState<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends ConsumerState<ErrorScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _retryCurrentRoute() {
    final currentUri = GoRouterState.of(context).uri.toString();
    context.go(currentUri);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _shakeAnimation.value * 10 * (1 - _shakeAnimation.value),
            0,
          ),
          child: child,
        );
      },
      child: SystemPageLayout(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          leading: const AppBackButton(
            fallback: Routes.welcome,
            icon: Icons.arrow_back,
            iconSize: 24,
          ),
        ),
        illustration: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: colors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(
              color: colors.error.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.error_outline_rounded,
            size: 70,
            color: colors.error,
          ),
        ),
        title: l10n.oopsSomethingWentWrong,
        subtitle: 'We encountered an unexpected issue.',
        body: SystemInfoCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: colors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    l10n.errorDetailsLabel,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                widget.error,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: _retryCurrentRoute,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                l10n.tryAgain,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.onPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/child/home');
                }
              },
              icon: const Icon(Icons.arrow_back_rounded),
              label: Text(
                l10n.goBack,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colors.outline),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.errorReported),
                  backgroundColor: context.successColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              );
            },
            icon: Icon(
              Icons.bug_report_outlined,
              color: colors.onSurfaceVariant,
            ),
            label: Text(
              l10n.reportIssue,
              style: textTheme.labelLarge?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
