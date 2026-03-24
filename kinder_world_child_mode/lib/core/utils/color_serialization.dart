import 'dart:ui';

int colorToArgb32(Color color) {
  final dynamic dynamicColor = color;

  try {
    return dynamicColor.toARGB32() as int;
  } on NoSuchMethodError {
    // ignore: deprecated_member_use
    final alpha = color.alpha;
    // ignore: deprecated_member_use
    final red = color.red;
    // ignore: deprecated_member_use
    final green = color.green;
    // ignore: deprecated_member_use
    final blue = color.blue;
    return (alpha << 24) | (red << 16) | (green << 8) | blue;
  }
}
