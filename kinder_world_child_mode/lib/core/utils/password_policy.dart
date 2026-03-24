import 'package:kinder_world/core/localization/app_localizations.dart';
import 'package:kinder_world/core/messages/app_messages.dart';
import 'package:kinder_world/core/localization/auth_error_localizer.dart';

final RegExp _passwordUppercasePattern = RegExp(r'[A-Z]');
final RegExp _passwordNumberPattern = RegExp(r'\d');
final RegExp _passwordSpecialPattern = RegExp(
  r'''[!@#$%^&*()_\-+=\[\]{};:'",.<>/?\\|`~]''',
);

abstract final class PasswordPolicy {
  static const int minLength = 8;

  static bool isSatisfied(String password) {
    return password.length >= minLength &&
        _passwordUppercasePattern.hasMatch(password) &&
        _passwordNumberPattern.hasMatch(password) &&
        _passwordSpecialPattern.hasMatch(password);
  }

  static String? validateForUi({
    required String password,
    required AppLocalizations l10n,
    required String emptyMessage,
  }) {
    if (password.trim().isEmpty) {
      return emptyMessage;
    }
    if (!isSatisfied(password)) {
      return l10n.passwordPolicyRequirement;
    }
    return null;
  }

  static String localizeControllerMessage(
    String message,
    AppLocalizations l10n,
  ) {
    switch (message) {
      case AuthUiMessages.currentPasswordCannotBeEmpty:
        return l10n.currentPasswordRequired;
      case AuthUiMessages.newPasswordCannotBeEmpty:
        return l10n.newPasswordRequired;
      case AuthUiMessages.passwordMinLength:
      case AuthUiMessages.passwordStrengthRequirement:
        return l10n.passwordPolicyRequirement;
      case AuthUiMessages.passwordsDoNotMatch:
        return l10n.passwordsDoNotMatch;
      case AuthUiMessages.failedToChangePasswordCheckCurrent:
      case AuthUiMessages.changePasswordUnexpected:
        return l10n.passwordChangeFailed;
      default:
        return localizeAuthErrorMessage(message, l10n);
    }
  }
}
