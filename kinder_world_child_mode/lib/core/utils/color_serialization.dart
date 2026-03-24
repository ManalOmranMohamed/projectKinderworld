import 'dart:ui';

int colorToArgb32(Color color) {
  int channel(double value) => (value * 255.0).round().clamp(0, 255);

  return (channel(color.a) << 24) |
      (channel(color.r) << 16) |
      (channel(color.g) << 8) |
      channel(color.b);
}
