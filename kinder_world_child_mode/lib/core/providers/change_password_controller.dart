import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kinder_world/core/providers/auth_controller.dart';
import 'package:kinder_world/core/services/auth_service.dart';
import 'package:logger/logger.dart';
import 'package:kinder_world/app.dart';

// Change password controller
final changePasswordControllerProvider = StateNotifierProvider.autoDispose<
    ChangePasswordController, AsyncValue<void>>(
  (ref) {
    final authService = ref.watch(authServiceProvider);
    final logger = ref.watch(loggerProvider);
    return ChangePasswordController(
      authService: authService,
      logger: logger,
    );
  },
);

class ChangePasswordController extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;
  final Logger _logger;
  static final RegExp _strongPassword = RegExp(
    r'''^(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_\-+=\[\]{};:'",.<>/?\\|`~]).{8,}$''',
  );

  ChangePasswordController({
    required AuthService authService,
    required Logger logger,
  })  : _authService = authService,
        _logger = logger,
        super(const AsyncValue.data(null));

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // Validation
    if (currentPassword.trim().isEmpty) {
      state = AsyncValue.error(
          'Current password cannot be empty', StackTrace.current);
      return false;
    }

    if (newPassword.trim().isEmpty) {
      state =
          AsyncValue.error('New password cannot be empty', StackTrace.current);
      return false;
    }

    if (newPassword.length < 6) {
      state = AsyncValue.error(
        'Password must be at least 8 characters',
        StackTrace.current,
      );
      return false;
    }

    if (!_strongPassword.hasMatch(newPassword)) {
      state = AsyncValue.error(
        'Password must include uppercase, number, and special character',
        StackTrace.current,
      );
      return false;
    }

    if (newPassword != confirmPassword) {
      state = AsyncValue.error('Passwords do not match', StackTrace.current);
      return false;
    }

    state = const AsyncValue.loading();

    try {
      final success = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (success) {
        state = const AsyncValue.data(null);
        return true;
      } else {
        state = AsyncValue.error(
          'Failed to change password. Please check your current password.',
          StackTrace.current,
        );
        return false;
      }
    } catch (e, st) {
      _logger.e('Error changing password: $e', stackTrace: st);
      state = AsyncValue.error(
        'An error occurred while changing password',
        st,
      );
      return false;
    }
  }
}
