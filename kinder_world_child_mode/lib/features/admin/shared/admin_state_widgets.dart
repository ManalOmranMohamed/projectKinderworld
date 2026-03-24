import 'package:flutter/material.dart';
import 'package:kinder_world/core/widgets/app_state_widgets.dart';
import 'package:kinder_world/core/utils/color_compat.dart';

class AdminPageHeader extends StatelessWidget {
  const AdminPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        final actionWrap = Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: compact ? WrapAlignment.start : WrapAlignment.end,
          children: actions,
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValuesCompat(alpha: 0.6),
                ),
              ),
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 12),
                actionWrap,
              ],
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValuesCompat(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(width: 12),
              Flexible(child: actionWrap),
            ],
          ],
        );
      },
    );
  }
}

class AdminLoadingState extends StatelessWidget {
  const AdminLoadingState({super.key, this.padding = const EdgeInsets.all(64)});

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return AppLoadingState.admin(padding: padding);
  }
}

class AdminErrorState extends StatelessWidget {
  const AdminErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AppErrorState.admin(message: message, onRetry: onRetry);
  }
}

class AdminEmptyState extends StatelessWidget {
  const AdminEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
    this.actionLabel,
  });

  final String message;
  final IconData icon;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState.admin(
      title: message,
      subtitle: '',
      icon: icon,
      action: action,
      actionLabel: actionLabel,
    );
  }
}
