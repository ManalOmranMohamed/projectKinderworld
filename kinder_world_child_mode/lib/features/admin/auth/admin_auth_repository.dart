import 'package:dio/dio.dart';
import 'package:kinder_world/core/api/admin_api.dart';
import 'package:kinder_world/core/models/admin_user.dart';
import 'package:kinder_world/core/storage/secure_storage.dart';

class AdminAuthResult {
  final bool success;
  final String? error;
  final AdminUser? admin;
  final String? accessToken;
  final String? refreshToken;

  const AdminAuthResult({
    required this.success,
    this.error,
    this.admin,
    this.accessToken,
    this.refreshToken,
  });

  factory AdminAuthResult.ok({
    AdminUser? admin,
    String? accessToken,
    String? refreshToken,
  }) {
    return AdminAuthResult(
      success: true,
      admin: admin,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  factory AdminAuthResult.fail(String error) {
    return AdminAuthResult(success: false, error: error);
  }
}

class AdminAuthRepository {
  final AdminApi _adminApi;
  final SecureStorage _storage;

  AdminAuthRepository({
    required AdminApi adminApi,
    required SecureStorage storage,
  })  : _adminApi = adminApi,
        _storage = storage;

  Future<AdminAuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final body = await _adminApi.login(email: email, password: password);
      final accessToken = body['access_token'] as String;
      final refreshToken = body['refresh_token'] as String;
      final adminJson = Map<String, dynamic>.from(body['admin'] as Map);
      final admin = AdminUser.fromJson(adminJson);

      await _persistSession(admin, accessToken, refreshToken);

      return AdminAuthResult.ok(
        admin: admin,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } on DioException catch (e) {
      return AdminAuthResult.fail(_extractError(e));
    } catch (e) {
      return AdminAuthResult.fail('Unexpected error: $e');
    }
  }

  Future<AdminAuthResult> refreshToken() async {
    try {
      final storedRefresh = await _storage.getAdminRefreshToken();
      if (storedRefresh == null || storedRefresh.isEmpty) {
        return AdminAuthResult.fail('No refresh token stored');
      }

      final body = await _adminApi.refresh(refreshToken: storedRefresh);
      final newAccessToken = body['access_token'] as String;

      await _storage.saveAdminToken(newAccessToken);

      return AdminAuthResult.ok(accessToken: newAccessToken);
    } on DioException catch (e) {
      return AdminAuthResult.fail(_extractError(e));
    } catch (e) {
      return AdminAuthResult.fail('Unexpected error: $e');
    }
  }

  Future<void> logout() async {
    try {
      final token = await _storage.getAdminToken();
      if (token != null && token.isNotEmpty) {
        await _adminApi.logout(accessToken: token);
      }
    } catch (_) {
      // Best-effort API call; local session is always cleared.
    } finally {
      await _storage.clearAdminSession();
    }
  }

  Future<AdminAuthResult> getMe() async {
    try {
      final token = await _storage.getAdminToken();
      if (token == null || token.isEmpty) {
        return AdminAuthResult.fail('Not authenticated');
      }

      final body = await _adminApi.me(accessToken: token);
      final adminJson = Map<String, dynamic>.from(body['admin'] as Map);
      final admin = AdminUser.fromJson(adminJson);

      await _storage.saveAdminName(admin.name);
      await _storage.saveAdminEmail(admin.email);
      await _storage.saveAdminRoles(admin.roles);
      await _storage.saveAdminPermissions(admin.permissions);

      return AdminAuthResult.ok(admin: admin);
    } on DioException catch (e) {
      return AdminAuthResult.fail(_extractError(e));
    } catch (e) {
      return AdminAuthResult.fail('Unexpected error: $e');
    }
  }

  Future<AdminUser?> restoreSession() async {
    try {
      final token = await _storage.getAdminToken();
      if (token == null || token.isEmpty) return null;

      final meResult = await getMe();
      if (meResult.success && meResult.admin != null) {
        return meResult.admin;
      }

      final refreshResult = await refreshToken();
      if (refreshResult.success) {
        final refreshedMe = await getMe();
        if (refreshedMe.success && refreshedMe.admin != null) {
          return refreshedMe.admin;
        }
      }

      await _storage.clearAdminSession();
      return null;
    } catch (_) {
      await _storage.clearAdminSession();
      return null;
    }
  }

  Future<void> _persistSession(
    AdminUser admin,
    String accessToken,
    String refreshToken,
  ) async {
    await _storage.saveAdminToken(accessToken);
    await _storage.saveAdminRefreshToken(refreshToken);
    await _storage.saveAdminId(admin.id.toString());
    await _storage.saveAdminEmail(admin.email);
    await _storage.saveAdminName(admin.name);
    await _storage.saveAdminRoles(admin.roles);
    await _storage.saveAdminPermissions(admin.permissions);
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final detail = data['detail'];
      if (detail is String) {
        return detail;
      }
      if (detail is Map) {
        return detail['message'] as String? ?? 'Request failed';
      }
    }
    switch (e.response?.statusCode) {
      case 401:
        return 'Invalid email or password';
      case 403:
        return 'Admin account is disabled';
      case 404:
        return 'Admin account not found';
      default:
        return e.message ?? 'Network error';
    }
  }
}
