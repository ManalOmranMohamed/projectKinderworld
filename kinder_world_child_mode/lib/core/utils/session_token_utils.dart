import 'dart:convert';

Map<String, dynamic>? tryDecodeJwtPayload(String token) {
  final trimmed = token.trim();
  if (trimmed.isEmpty) return null;

  final parts = trimmed.split('.');
  if (parts.length != 3) return null;

  try {
    final normalized = base64Url.normalize(parts[1]);
    final decoded = jsonDecode(utf8.decode(base64Url.decode(normalized)));
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
  } catch (_) {
    return null;
  }

  return null;
}

bool isLegacyChildSessionMarker(String? token) {
  if (token == null) return false;
  return token.trim().startsWith('child_session_');
}

bool isChildSessionToken(String? token) {
  if (token == null) return false;
  final trimmed = token.trim();
  if (trimmed.isEmpty) return false;
  if (isLegacyChildSessionMarker(trimmed)) return true;

  final payload = tryDecodeJwtPayload(trimmed);
  return payload?['token_type']?.toString() == 'child_session';
}

bool isJwtExpired(String token) {
  final payload = tryDecodeJwtPayload(token);
  if (payload == null) return false;

  final exp = payload['exp'];
  final expSeconds = exp is int ? exp : int.tryParse(exp?.toString() ?? '');
  if (expSeconds == null) return false;

  final expiresAt = DateTime.fromMillisecondsSinceEpoch(
    expSeconds * 1000,
    isUtc: true,
  );
  return expiresAt.isBefore(DateTime.now().toUtc());
}
