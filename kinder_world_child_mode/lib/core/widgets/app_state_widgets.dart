import 'package:flutter/material.dart';
import 'package:kinder_world/core/localization/app_localizations.dart';
import 'package:kinder_world/core/widgets/child_design_system.dart';
import 'package:kinder_world/core/widgets/parent_design_system.dart';

enum AppStateVariant { child, parent, admin }

class AppLoadingState extends StatelessWidget {
  const AppLoadingState.child({
    super.key,
    this.padding = const EdgeInsets.all(32),
    this.message,
  }) : variant = AppStateVariant.child;

  const AppLoadingState.parent({
    super.key,
    this.padding = const EdgeInsets.all(32),
    this.message,
  }) : variant = AppStateVariant.parent;

  const AppLoadingState.admin({
    super.key,
    this.padding = const EdgeInsets.all(64),
    this.message,
  }) : variant = AppStateVariant.admin;

  final AppStateVariant variant;
  final EdgeInsets padding;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final resolvedMessage = message ?? l10n.loading;

    switch (variant) {
      case AppStateVariant.child:
        return Padding(
          padding: padding,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  resolvedMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      case AppStateVariant.parent:
        return Padding(
          padding: padding,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  resolvedMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      case AppStateVariant.admin:
        return Padding(
          padding: padding,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  resolvedMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
    }
  }
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState.child({
    super.key,
    required this.title,
    required this.subtitle,
    this.action,
    this.actionLabel,
    this.emoji = '✨',
    this.icon,
  }) : variant = AppStateVariant.child;

  const AppEmptyState.parent({
    super.key,
    required this.title,
    required this.subtitle,
    this.action,
    this.actionLabel,
    this.icon = Icons.inbox_outlined,
    this.emoji,
  }) : variant = AppStateVariant.parent;

  const AppEmptyState.admin({
    super.key,
    required this.title,
    required this.subtitle,
    this.action,
    this.actionLabel,
    this.icon = Icons.inbox_outlined,
    this.emoji,
  }) : variant = AppStateVariant.admin;

  final AppStateVariant variant;
  final String title;
  final String subtitle;
  final VoidCallback? action;
  final String? actionLabel;
  final IconData? icon;
  final String? emoji;

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case AppStateVariant.child:
        return ChildEmptyState(
          emoji: emoji ?? '✨',
          title: title,
          subtitle: subtitle,
          action: _buildAction(),
        );
      case AppStateVariant.parent:
        return ParentEmptyState(
          icon: icon ?? Icons.inbox_outlined,
          title: title,
          subtitle: subtitle,
          action: _buildAction(),
        );
      case AppStateVariant.admin:
        final colorScheme = Theme.of(context).colorScheme;
        final theme = Theme.of(context);

        return Card(
          elevation: 0,
          color: colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon ?? Icons.inbox_outlined,
                      size: 32,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (action != null && actionLabel != null) ...[
                    const SizedBox(height: 16),
                    FilledButton.tonal(
                      onPressed: action,
                      child: Text(actionLabel!),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
    }
  }

  Widget? _buildAction() {
    if (action == null || actionLabel == null) return null;
    return FilledButton.tonal(
      onPressed: action,
      child: Text(actionLabel!),
    );
  }
}

class AppErrorState extends StatelessWidget {
  const AppErrorState.child({
    super.key,
    required this.message,
    this.onRetry,
    this.buttonLabel,
    this.padding = const EdgeInsets.all(24),
  }) : variant = AppStateVariant.child;

  const AppErrorState.parent({
    super.key,
    required this.message,
    this.onRetry,
    this.buttonLabel,
    this.padding = const EdgeInsets.all(24),
  }) : variant = AppStateVariant.parent;

  const AppErrorState.admin({
    super.key,
    required this.message,
    this.onRetry,
    this.buttonLabel,
    this.padding = EdgeInsets.zero,
  }) : variant = AppStateVariant.admin;

  final AppStateVariant variant;
  final String message;
  final VoidCallback? onRetry;
  final String? buttonLabel;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final resolvedButtonLabel = buttonLabel ?? l10n.retryAction;

    switch (variant) {
      case AppStateVariant.child:
        return Padding(
          padding: padding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 40,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.errorTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onErrorContainer,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onErrorContainer,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (onRetry != null) ...[
                        const SizedBox(height: 18),
                        FilledButton.tonalIcon(
                          onPressed: onRetry,
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(resolvedButtonLabel),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      case AppStateVariant.parent:
        return Padding(
          padding: padding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                color: colorScheme.errorContainer.withValues(alpha: 0.3),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: colorScheme.error.withValues(alpha: 0.2),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 30,
                        color: colorScheme.error,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        l10n.errorTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (onRetry != null) ...[
                        const SizedBox(height: 18),
                        FilledButton.tonalIcon(
                          onPressed: onRetry,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: Text(resolvedButtonLabel),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      case AppStateVariant.admin:
        return Padding(
          padding: padding,
          child: Card(
            color: colorScheme.errorContainer.withValues(alpha: 0.35),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: colorScheme.error.withValues(alpha: 0.25),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      color: colorScheme.error,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.errorTitle,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        if (onRetry != null) ...[
                          const SizedBox(height: 12),
                          FilledButton.tonalIcon(
                            onPressed: onRetry,
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: Text(resolvedButtonLabel),
                            style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.errorContainer,
                              foregroundColor: colorScheme.error,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}
