import 'package:flutter/material.dart';

class ThemedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final Color? surfaceColor;
  final Color? onSurfaceColor;

  const ThemedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.border,
    this.boxShadow,
    this.surfaceColor,
    this.onSurfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final surface = surfaceColor ?? colors.surface;
    final onSurface = onSurfaceColor ?? colors.onSurface;

    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: borderRadius,
        border: border,
        boxShadow: boxShadow,
      ),
      child: DefaultTextStyle.merge(
        style: textTheme.bodyMedium?.copyWith(color: onSurface),
        child: IconTheme.merge(
          data: IconThemeData(color: onSurface),
          child: child,
        ),
      ),
    );
  }
}

class ThemedContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry borderRadius;
  final BoxBorder? border;
  final Color? surfaceColor;
  final Color? onSurfaceColor;

  const ThemedContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.border,
    this.surfaceColor,
    this.onSurfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final surface = surfaceColor ?? colors.surface;
    final onSurface = onSurfaceColor ?? colors.onSurface;

    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: borderRadius,
        border: border,
      ),
      child: DefaultTextStyle.merge(
        style: textTheme.bodyMedium?.copyWith(color: onSurface),
        child: IconTheme.merge(
          data: IconThemeData(color: onSurface),
          child: child,
        ),
      ),
    );
  }
}
