import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Unified avatar display widget that handles both avatar paths and avatar IDs
/// Maps avatar_1, avatar_2, avatar_3, avatar_4 to their corresponding icons
class AvatarView extends StatelessWidget {
  final String? avatarPath; // Direct asset path (e.g., 'assets/images/avatars/boy_01.png')
  final String? avatarId; // Avatar ID (e.g., 'avatar_1', 'avatar_2')
  final double radius;
  final BoxFit fit;
  final Color? backgroundColor;
  final String fallbackAsset;

  // Avatar ID to icon data mapping
  static const Map<String, _AvatarIconData> _avatarIconMap = {
    'avatar_1': _AvatarIconData(
      icon: Icons.face,
      backgroundColor: Color(0xFFE3F2FD),
      iconColor: Color(0xFF1E88E5),
    ),
    'avatar_2': _AvatarIconData(
      icon: Icons.sentiment_satisfied_alt,
      backgroundColor: Color(0xFFFFF3E0),
      iconColor: Color(0xFFFB8C00),
    ),
    'avatar_3': _AvatarIconData(
      icon: Icons.emoji_emotions,
      backgroundColor: Color(0xFFF3E5F5),
      iconColor: Color(0xFF8E24AA),
    ),
    'avatar_4': _AvatarIconData(
      icon: Icons.mood,
      backgroundColor: Color(0xFFE8F5E9),
      iconColor: Color(0xFF43A047),
    ),
    'avatar_5': _AvatarIconData(
      icon: Icons.star,
      backgroundColor: Color(0xFFFFF9C4),
      iconColor: Color(0xFFF57F17),
    ),
    'avatar_6': _AvatarIconData(
      icon: Icons.pets,
      backgroundColor: Color(0xFFFFE0B2),
      iconColor: Color(0xFFE65100),
    ),
    'avatar_7': _AvatarIconData(
      icon: Icons.favorite,
      backgroundColor: Color(0xFFFCE4EC),
      iconColor: Color(0xFFC2185B),
    ),
    'avatar_8': _AvatarIconData(
      icon: Icons.rocket_launch,
      backgroundColor: Color(0xFFE1F5FE),
      iconColor: Color(0xFF0277BD),
    ),
    'avatar_neutral': _AvatarIconData(
      icon: Icons.account_circle,
      backgroundColor: Color(0xFFE0E0E0),
      iconColor: Color(0xFF757575),
    ),
  };

  static const Map<String, String> _legacyAvatarMap = {
    'assets/avatars/kids/boy_01.png': 'assets/images/avatars/boy1.png',
    'assets/avatars/kids/boy_02.png': 'assets/images/avatars/boy2.png',
    'assets/avatars/kids/girl_01.png': 'assets/images/avatars/girl1.png',
    'assets/avatars/kids/girl_02.png': 'assets/images/avatars/girl2.png',
    'assets/avatars/kids/neutral_01.png': 'assets/images/avatars/girl1.png',
  };

  const AvatarView({
    this.avatarPath,
    this.avatarId,
    this.radius = 24,
    this.fit = BoxFit.cover,
    this.backgroundColor,
    this.fallbackAsset = 'assets/images/avatars/girl1.png',
    super.key,
  });

  /// Get icon data from avatarId
  _AvatarIconData? _resolveIconData() {
    if (avatarId != null && _avatarIconMap.containsKey(avatarId)) {
      return _avatarIconMap[avatarId];
    }
    return null;
  }

  /// Get asset path from either avatarPath or avatarId (legacy support)
  String? _resolvePath() {
    if (avatarPath != null && avatarPath!.isNotEmpty) {
      return _normalizeAssetPath(avatarPath!);
    }
    if (avatarId != null && avatarId!.isNotEmpty) {
      return _normalizeAssetPath(avatarId!);
    }
    return null;
  }

  String _normalizeAssetPath(String path) {
    return _legacyAvatarMap[path] ?? path;
  }

  bool _isNetworkImage(String path) {
    final uri = Uri.tryParse(path);
    return uri != null && uri.hasAbsolutePath &&
        (path.startsWith('http://') || path.startsWith('https://'));
  }

  @override
  Widget build(BuildContext context) {
    // First try to get icon data (new approach)
    final iconData = _resolveIconData();
    if (iconData != null) {
      return Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          color: backgroundColor ?? iconData.backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          iconData.icon,
          size: radius * 1.2,
          color: iconData.iconColor,
        ),
      );
    }

    // Fallback to image path (legacy support)
    final resolvedPath = _resolvePath();
    const fallbackImage = 'assets/images/avatars/girl1.png';
    
    if (resolvedPath != null && _isNetworkImage(resolvedPath)) {
      return CachedNetworkImage(
        imageUrl: resolvedPath,
        imageBuilder: (context, provider) => CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor ?? Colors.transparent,
          backgroundImage: provider,
        ),
        errorWidget: (context, url, error) => CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor ?? Colors.transparent,
          backgroundImage: AssetImage(fallbackImage),
        ),
        placeholder: (context, url) => CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor ?? Colors.transparent,
          backgroundImage: AssetImage(fallbackImage),
        ),
      );
    }

    final assetPath = resolvedPath ?? fallbackImage;
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.transparent,
      backgroundImage: AssetImage(assetPath),
    );
  }
}

class _AvatarIconData {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const _AvatarIconData({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });
}
