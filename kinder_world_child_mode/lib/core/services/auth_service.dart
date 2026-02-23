import 'package:kinder_world/core/network/network_service.dart';
import 'package:kinder_world/core/repositories/auth_repository.dart';
import 'package:kinder_world/core/models/user.dart';
import 'package:logger/logger.dart';

/// Service wrapper for authentication operations
class AuthService {
  final AuthRepository _repository;
  final NetworkService _networkService;
  final Logger _logger;

  AuthService({
    required AuthRepository repository,
    required NetworkService networkService,
    required Logger logger,
  })  : _repository = repository,
        _networkService = networkService,
        _logger = logger;

  /// Get current user
  Future<User?> getMe() async {
    return await _repository.getMe();
  }

  /// Update parent profile
  Future<bool> updateProfile({required String name}) async {
    try {
      final response = await _networkService.put<Map<String, dynamic>>(
        '/auth/profile',
        data: {
          'name': name.trim(),
        },
      );

      final success = response.data != null;
      if (success) {
        _logger.d('Profile updated successfully');
      }
      return success;
    } catch (e) {
      _logger.e('Error updating profile: $e');
      return false;
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _networkService.post<Map<String, dynamic>>(
        '/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      final success =
          response.data != null && response.data!['success'] == true;
      if (success) {
        _logger.d('Password changed successfully');
      }
      return success;
    } catch (e) {
      _logger.e('Error changing password: $e');
      return false;
    }
  }

  // Delegate repository methods
  Future<User?> loginParent({
    required String email,
    required String password,
  }) async {
    return await _repository.loginParent(email: email, password: password);
  }

  Future<User?> registerParent({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    return await _repository.registerParent(
      name: name,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
  }

  Future<bool> logout() async {
    return await _repository.logout();
  }

  Future<String?> getUserRole() async {
    return await _repository.getUserRole();
  }
}
