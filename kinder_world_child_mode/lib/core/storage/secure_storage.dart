import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage service for sensitive data
class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // Storage keys
  static const String _keyAuthToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserRole = 'user_role';
  static const String _keyParentPin = 'parent_pin';
  static const String _keyChildSession = 'child_session';
  static const String _keyIsPremium = 'is_premium';
  static const String _keyPlanType = 'plan_type';

  // ==================== AUTH TOKEN ====================

  Future<String?> getAuthToken() async {
    try {
      return await _storage.read(key: _keyAuthToken);
    } catch (e) {
      return null;
    }
  }

  Future<bool> saveAuthToken(String token) async {
    try {
      await _storage.write(key: _keyAuthToken, value: token);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteAuthToken() async {
    try {
      await _storage.delete(key: _keyAuthToken);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== REFRESH TOKEN ====================

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _keyRefreshToken);
    } catch (e) {
      return null;
    }
  }

  Future<bool> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _keyRefreshToken, value: token);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteRefreshToken() async {
    try {
      await _storage.delete(key: _keyRefreshToken);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== USER ID ====================

  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _keyUserId);
    } catch (e) {
      return null;
    }
  }

  Future<bool> saveUserId(String userId) async {
    try {
      await _storage.write(key: _keyUserId, value: userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteUserId() async {
    try {
      await _storage.delete(key: _keyUserId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== USER EMAIL ====================

  Future<String?> getUserEmail() async {
    try {
      return await _storage.read(key: _keyUserEmail);
    } catch (e) {
      return null;
    }
  }

  Future<bool> saveUserEmail(String email) async {
    try {
      await _storage.write(key: _keyUserEmail, value: email);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteUserEmail() async {
    try {
      await _storage.delete(key: _keyUserEmail);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== USER ROLE ====================

  Future<String?> getUserRole() async {
    try {
      return await _storage.read(key: _keyUserRole);
    } catch (e) {
      return null;
    }
  }

  Future<bool> saveUserRole(String role) async {
    try {
      await _storage.write(key: _keyUserRole, value: role);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteUserRole() async {
    try {
      await _storage.delete(key: _keyUserRole);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== PARENT PIN ====================

  Future<String?> getParentPin() async {
    try {
      return await _storage.read(key: _keyParentPin);
    } catch (e) {
      return null;
    }
  }

  Future<bool> saveParentPin(String pin) async {
    try {
      await _storage.write(key: _keyParentPin, value: pin);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteParentPin() async {
    try {
      await _storage.delete(key: _keyParentPin);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> hasParentPin() async {
    try {
      final pin = await getParentPin();
      return pin != null && pin.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // ==================== CHILD SESSION ====================

  Future<String?> getChildSession() async {
    try {
      return await _storage.read(key: _keyChildSession);
    } catch (e) {
      return null;
    }
  }

  Future<bool> saveChildSession(String childId) async {
    try {
      await _storage.write(key: _keyChildSession, value: childId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearChildSession() async {
    try {
      await _storage.delete(key: _keyChildSession);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== PREMIUM STATUS ====================

  Future<bool?> getIsPremium() async {
    try {
      final value = await _storage.read(key: _keyIsPremium);
      if (value == null) return null;
      return value == 'true';
    } catch (e) {
      return null;
    }
  }

  Future<bool> saveIsPremium(bool isPremium) async {
    try {
      await _storage.write(
        key: _keyIsPremium,
        value: isPremium ? 'true' : 'false',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearIsPremium() async {
    try {
      await _storage.delete(key: _keyIsPremium);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== PLAN TYPE ====================

  Future<String?> getPlanType() async {
    try {
      return await _storage.read(key: _keyPlanType);
    } catch (e) {
      return null;
    }
  }

  Future<bool> savePlanType(String planType) async {
    try {
      await _storage.write(key: _keyPlanType, value: planType);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearPlanType() async {
    try {
      await _storage.delete(key: _keyPlanType);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== CLEAR ALL ====================

  Future<bool> clearAll() async {
    try {
      await _storage.deleteAll();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear only authentication/session data while preserving child profiles and preferences
  /// Use this for logout to keep local child data intact
  Future<bool> clearAuthOnly() async {
    try {
      // Clear auth tokens and session
      await _storage.delete(key: _keyAuthToken);
      await _storage.delete(key: _keyUserRole);
      await _storage.delete(key: _keyUserId);
      await _storage.delete(key: _keyUserEmail);
      await _storage.delete(key: _keyChildSession);
      await _storage.delete(key: _keyParentPin);
      
      // Preserve: child profiles, plan type, theme settings, privacy settings
      // These are accessible without authentication
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== HELPERS ====================

  Future<bool> isAuthenticated() async {
    try {
      final token = await getAuthToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, String>> getAllSecureData() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      return {};
    }
  }

  /// Backwards-compatible alias for getting the parent id (previous API used getParentId)
  Future<String?> getParentId() async => getUserId();

  /// Backwards-compatible alias for getting the parent email
  Future<String?> getParentEmail() async => getUserEmail();
}
