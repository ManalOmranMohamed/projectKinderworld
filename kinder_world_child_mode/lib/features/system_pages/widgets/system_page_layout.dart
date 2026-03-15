import 'package:flutter/material.dart';
import 'package:kinder_world/core/constants/app_constants.dart';

class SystemPageLayout extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget illustration;
  final String title;
  final String subtitle;
  final Widget? body;
  final List<Widget> actions;

  const SystemPageLayout({
    super.key,
    this.appBar,
    required this.illustration,
    required this.title,
    required this.subtitle,
    this.body,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: appBar,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding,
                vertical: AppSpacing.xxl,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (AppSpacing.xxl * 2),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: illustration,
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colors.onSurfaceVariant,
                            height: 1.45,
                          ),
                        ),
                        if (body != null) ...[
                          const SizedBox(height: AppSpacing.xxxl),
                          body!,
                        ],
                        if (actions.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xxxl),
                          ...actions,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SystemInfoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const SystemInfoCard({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: child,
    );
  }
}
