import 'dart:ui';

extension ColorWithValuesCompat on Color {
  Color withValuesCompat({double? alpha}) {
    if (alpha == null) {
      return this;
    }
    final normalized = alpha.clamp(0.0, 1.0);
    return withAlpha((normalized * 255).round());
  }

  Color withValues({double? alpha}) {
    return withValuesCompat(alpha: alpha);
  }
}
