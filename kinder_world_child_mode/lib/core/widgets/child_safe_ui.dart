import 'package:flutter/material.dart';
import 'package:kinder_world/core/theme/theme_extensions.dart';

void showChildFeedbackSnackBar(
  BuildContext context,
  String message, {
  bool success = true,
}) {
  final theme = Theme.of(context);
  final bg = success ? context.childTheme.success : theme.colorScheme.error;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
      duration: const Duration(seconds: 2),
      backgroundColor: bg,
      content: Text(
        message,
        style: theme.textTheme.labelLarge?.copyWith(
          color: bg.onColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

class ChildPrimaryActionButton extends StatelessWidget {
  const ChildPrimaryActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.semanticLabel,
    this.backgroundColor,
    this.foregroundColor,
    this.isBusy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? semanticLabel;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? colors.primary;
    final fg = foregroundColor ?? bg.onColor;
    final child = isBusy
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.6,
              color: fg,
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: fg),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: fg,
                  ),
                ),
              ),
            ],
          );

    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isBusy ? null : onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            backgroundColor: bg,
            foregroundColor: fg,
          ),
          child: child,
        ),
      ),
    );
  }
}
