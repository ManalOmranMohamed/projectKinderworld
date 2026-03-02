import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColoringProgressData {
  const ColoringProgressData({
    required this.colors,
    required this.isCompleted,
  });

  final Map<String, Color> colors;
  final bool isCompleted;
}

class ColoringProgressStorage {
  static const String _prefix = 'coloring_progress_v1_';

  static Future<ColoringProgressData> load(String svgAssetPath) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(svgAssetPath));
    if (raw == null || raw.isEmpty) {
      return const ColoringProgressData(
          colors: <String, Color>{}, isCompleted: false);
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const ColoringProgressData(
            colors: <String, Color>{}, isCompleted: false);
      }

      final colors = <String, Color>{};
      final colorMap = decoded['colors'];
      if (colorMap is Map) {
        colorMap.forEach((key, value) {
          if (key is String && value is String) {
            final parsed = _parseColor(value);
            if (parsed != null && parsed != Colors.white) {
              colors[key] = parsed;
            }
          }
        });
      }

      final completed = decoded['completed'] == true;
      return ColoringProgressData(colors: colors, isCompleted: completed);
    } catch (_) {
      return const ColoringProgressData(
          colors: <String, Color>{}, isCompleted: false);
    }
  }

  static Future<void> save({
    required String svgAssetPath,
    required Map<String, Color> colors,
    required bool isCompleted,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = <String, dynamic>{
      'completed': isCompleted,
      'colors': colors.map(
        (key, value) => MapEntry(key, _toHex(value)),
      ),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    await prefs.setString(_key(svgAssetPath), jsonEncode(payload));
  }

  static String _key(String svgAssetPath) =>
      '$_prefix${base64Url.encode(utf8.encode(svgAssetPath))}';

  static Color? _parseColor(String hex) {
    final normalized = hex.replaceAll('#', '').toUpperCase();
    if (normalized.length != 6 && normalized.length != 8) return null;

    final argb = normalized.length == 8 ? normalized : 'FF$normalized';
    final value = int.tryParse(argb, radix: 16);
    if (value == null) return null;
    return Color(value);
  }

  static String _toHex(Color color) {
    final argb = color.toARGB32();
    return '#${argb.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }
}
