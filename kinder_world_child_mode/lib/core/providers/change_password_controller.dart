import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kinder_world/core/messages/app_messages.dart';
import 'package:kinder_world/core/providers/auth_controller.dart';
import 'package:kinder_world/core/services/auth_service.dart';
import 'package:kinder_world/core/utils/password_policy.dart';
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

  ChangePasswordController({
    required AuthService authService,
    required Logger logger,
  })  : _authService = authService,
        _logger = logger,
        super(const AsyncValue.data(null));

  void setValidationError(String message) {
    state = AsyncValue.error(message, StackTrace.current);
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // Validation
    if (currentPassword.trim().isEmpty) {
      state = AsyncValue.error(
        AuthUiMessages.currentPasswordCannotBeEmpty,
        StackTrace.current,
      );
      return false;
    }

    if (newPassword.trim().isEmpty) {
      state = AsyncValue.error(
        AuthUiMessages.newPasswordCannotBeEmpty,
        StackTrace.current,
      );
      return false;
    }

    if (!PasswordPolicy.isSatisfied(newPassword)) {
      state = AsyncValue.error(
        AuthUiMessages.passwordStrengthRequirement,
        StackTrace.current,
      );
      return false;
    }

    if (newPassword != confirmPassword) {
      state = AsyncValue.error(
        AuthUiMessages.passwordsDoNotMatch,
        StackTrace.current,
      );
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
          AuthUiMessages.failedToChangePasswordCheckCurrent,
          StackTrace.current,
        );
        return false;
      }
    } catch (e, st) {
      _logger.e('Error changing password: $e', stackTrace: st);
      state = AsyncValue.error(
        AuthUiMessages.changePasswordUnexpected,
        st,
      );
      return false;
    }
  }
}
