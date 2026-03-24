import 'package:flutter/material.dart';

enum AppSkeletonVariant { child, parent, admin }

class AppSkeletonBox extends StatelessWidget {
  const AppSkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 16,
    this.variant = AppSkeletonVariant.parent,
  });

  final double? width;
  final double height;
  final double radius;
  final AppSkeletonVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final base = _baseColor(colors);
    final highlight = Color.lerp(base, colors.surface, 0.45) ?? base;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            base,
            highlight,
          ],
        ),
      ),
    );
  }

  Color _baseColor(ColorScheme colors) {
    switch (variant) {
      case AppSkeletonVariant.child:
        return Color.lerp(
                colors.primary, colors.surfaceContainerHighest, 0.85) ??
            colors.surfaceContainerHighest;
      case AppSkeletonVariant.parent:
        return Color.lerp(
              colors.secondary,
              colors.surfaceContainerHighest,
              0.9,
            ) ??
            colors.surfaceContainerHighest;
      case AppSkeletonVariant.admin:
        return Color.lerp(
                colors.outlineVariant, colors.surfaceContainerHighest, 0.8) ??
            colors.surfaceContainerHighest;
    }
  }
}

class AppSkeletonCircle extends StatelessWidget {
  const AppSkeletonCircle({
    super.key,
    required this.size,
    this.variant = AppSkeletonVariant.parent,
  });

  final double size;
  final AppSkeletonVariant variant;

  @override
  Widget build(BuildContext context) {
    return AppSkeletonBox(
      width: size,
      height: size,
      radius: size / 2,
      variant: variant,
    );
  }
}

class AppSkeletonCard extends StatelessWidget {
  const AppSkeletonCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.variant = AppSkeletonVariant.parent,
  });

  final Widget child;
  final EdgeInsets padding;
  final AppSkeletonVariant variant;


  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background = switch (variant) {
      AppSkeletonVariant.child => colors.surfaceContainerLow,
      AppSkeletonVariant.parent => colors.surface,
      AppSkeletonVariant.admin => colors.surfaceContainerLow,
    };

    return Card(
      elevation: 0,
      color: background,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

class ChildHomeSkeleton extends StatelessWidget {
  const ChildHomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          floating: true,
          title: const Row(
            children: [
              AppSkeletonCircle(
                size: 40,
                variant: AppSkeletonVariant.child,
              ),
              SizedBox(width: 12),
              Expanded(
                child: AppSkeletonBox(
                  height: 16,
                  variant: AppSkeletonVariant.child,
                ),
              ),
            ],
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonCard(
                  variant: AppSkeletonVariant.child,
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSkeletonBox(
                        width: 120,
                        height: 14,
                        radius: 10,
                        variant: AppSkeletonVariant.child,
                      ),
                      SizedBox(height: 12),
                      AppSkeletonBox(
                        width: 180,
                        height: 36,
                        radius: 14,
                        variant: AppSkeletonVariant.child,
                      ),
                      SizedBox(height: 18),
                      AppSkeletonBox(
                        width: double.infinity,
                        height: 96,
                        radius: 20,
                        variant: AppSkeletonVariant.child,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: AppSkeletonBox(
                        height: 88,
                        variant: AppSkeletonVariant.child,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: AppSkeletonBox(
                        height: 88,
                        variant: AppSkeletonVariant.child,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: AppSkeletonBox(
                        height: 88,
                        variant: AppSkeletonVariant.child,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                AppSkeletonCard(
                  variant: AppSkeletonVariant.child,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSkeletonBox(
                        width: 130,
                        height: 16,
                        radius: 10,
                        variant: AppSkeletonVariant.child,
                      ),
                      SizedBox(height: 14),
                      AppSkeletonBox(
                        width: double.infinity,
                        height: 120,
                        radius: 18,
                        variant: AppSkeletonVariant.child,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                AppSkeletonCard(
                  variant: AppSkeletonVariant.child,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSkeletonBox(
                        width: 150,
                        height: 16,
                        radius: 10,
                        variant: AppSkeletonVariant.child,
                      ),
                      SizedBox(height: 14),
                      AppSkeletonBox(
                        width: double.infinity,
                        height: 18,
                        radius: 10,
                        variant: AppSkeletonVariant.child,
                      ),
                      SizedBox(height: 10),
                      AppSkeletonBox(
                        width: double.infinity,
                        height: 18,
                        radius: 10,
                        variant: AppSkeletonVariant.child,
                      ),
                      SizedBox(height: 10),
                      AppSkeletonBox(
                        width: 210,
                        height: 18,
                        radius: 10,
                        variant: AppSkeletonVariant.child,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                AppSkeletonBox(
                  width: double.infinity,
                  height: 120,
                  radius: 24,
                  variant: AppSkeletonVariant.child,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ParentDashboardSkeleton extends StatelessWidget {
  const ParentDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      children: const [
        AppSkeletonBox(
          width: double.infinity,
          height: 120,
          radius: 28,
          variant: AppSkeletonVariant.parent,
        ),
        SizedBox(height: 20),
        AppSkeletonBox(
          width: double.infinity,
          height: 64,
          radius: 18,
          variant: AppSkeletonVariant.parent,
        ),
        SizedBox(height: 20),
        AppSkeletonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeletonBox(
                width: 150,
                height: 16,
                radius: 10,
              ),
              SizedBox(height: 14),
              AppSkeletonBox(
                width: double.infinity,
                height: 18,
                radius: 10,
              ),
              SizedBox(height: 12),
              AppSkeletonBox(
                width: double.infinity,
                height: 18,
                radius: 10,
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 164,
              child: AppSkeletonBox(height: 120),
            ),
            SizedBox(
              width: 164,
              child: AppSkeletonBox(height: 120),
            ),
            SizedBox(
              width: 164,
              child: AppSkeletonBox(height: 120),
            ),
          ],
        ),
        SizedBox(height: 20),
        AppSkeletonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeletonBox(
                width: 180,
                height: 16,
                radius: 10,
              ),
              SizedBox(height: 14),
              AppSkeletonBox(
                width: double.infinity,
                height: 150,
                radius: 18,
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        AppSkeletonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeletonBox(
                width: 160,
                height: 16,
                radius: 10,
              ),
              SizedBox(height: 14),
              AppSkeletonBox(
                width: double.infinity,
                height: 190,
                radius: 18,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AdminOverviewSkeleton extends StatelessWidget {
  const AdminOverviewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 220,
              child: AppSkeletonBox(
                height: 124,
                variant: AppSkeletonVariant.admin,
              ),
            ),
            SizedBox(
              width: 220,
              child: AppSkeletonBox(
                height: 124,
                variant: AppSkeletonVariant.admin,
              ),
            ),
            SizedBox(
              width: 220,
              child: AppSkeletonBox(
                height: 124,
                variant: AppSkeletonVariant.admin,
              ),
            ),
            SizedBox(
              width: 220,
              child: AppSkeletonBox(
                height: 124,
                variant: AppSkeletonVariant.admin,
              ),
            ),
          ],
        ),
        SizedBox(height: 24),
        AppSkeletonCard(
          variant: AppSkeletonVariant.admin,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeletonBox(
                width: 170,
                height: 16,
                radius: 10,
                variant: AppSkeletonVariant.admin,
              ),
              SizedBox(height: 14),
              AppSkeletonBox(
                width: double.infinity,
                height: 18,
                radius: 10,
                variant: AppSkeletonVariant.admin,
              ),
              SizedBox(height: 10),
              AppSkeletonBox(
                width: double.infinity,
                height: 18,
                radius: 10,
                variant: AppSkeletonVariant.admin,
              ),
              SizedBox(height: 10),
              AppSkeletonBox(
                width: 240,
                height: 18,
                radius: 10,
                variant: AppSkeletonVariant.admin,
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        AppSkeletonCard(
          variant: AppSkeletonVariant.admin,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeletonBox(
                width: 190,
                height: 16,
                radius: 10,
                variant: AppSkeletonVariant.admin,
              ),
              SizedBox(height: 14),
              AppSkeletonBox(
                width: double.infinity,
                height: 140,
                radius: 18,
                variant: AppSkeletonVariant.admin,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
