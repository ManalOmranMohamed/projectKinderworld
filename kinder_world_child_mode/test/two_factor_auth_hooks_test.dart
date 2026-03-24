import 'package:flutter_test/flutter_test.dart';
import 'package:kinder_world/core/api/admin_api.dart';
import 'package:kinder_world/core/models/admin_user.dart';
import 'package:kinder_world/core/navigation/app_navigation_controller.dart';
import 'package:kinder_world/core/network/network_service.dart';
import 'package:kinder_world/core/storage/secure_storage.dart';
import 'package:kinder_world/features/admin/auth/admin_auth_provider.dart';
import 'package:kinder_world/features/admin/auth/admin_auth_repository.dart';
import 'package:logger/logger.dart';

class _TestSecureStorage extends SecureStorage {}

class _FakeAdminAuthRepository extends AdminAuthRepository {
  _FakeAdminAuthRepository({
    required this.loginResult,
  }) : super(
          adminApi: AdminApi(
            NetworkService(
              secureStorage: _TestSecureStorage(),
              logger: Logger(),
            ),
          ),
          storage: _TestSecureStorage(),
        );

  final AdminAuthResult loginResult;
  String? lastTwoFactorCode;

  @override
  Future<AdminUser?> restoreSession() async => null;

  @override
  Future<AdminAuthResult> login({
    required String email,
    required String password,
    String? twoFactorCode,
  }) async {
    lastTwoFactorCode = twoFactorCode;
    return loginResult;
  }
}

void main() {
  test('admin auth notifier exposes two-factor challenge state', () async {
    final repo = _FakeAdminAuthRepository(
      loginResult: AdminAuthResult.fail(
        'Two-factor authentication code is required',
        requiresTwoFactor: true,
        twoFactorMethod: 'totp',
      ),
    );
    final notifier = AdminAuthNotifier(repo, AppNavigationController());

    await Future<void>.delayed(Duration.zero);
    final success = await notifier.login(
      email: 'admin@kinderworld.app',
      password: 'Admin@123456',
    );

    expect(success, isFalse);
    expect(notifier.state.requiresTwoFactor, isTrue);
    expect(notifier.state.twoFactorMethod, 'totp');
    expect(
      notifier.state.errorMessage,
      'Two-factor authentication code is required',
    );
  });

  test('admin auth notifier forwards optional two-factor code', () async {
    final repo = _FakeAdminAuthRepository(
      loginResult: AdminAuthResult.fail(
        'Invalid two-factor authentication code',
      ),
    );
    final notifier = AdminAuthNotifier(repo, AppNavigationController());

    await Future<void>.delayed(Duration.zero);
    await notifier.login(
      email: 'admin@kinderworld.app',
      password: 'Admin@123456',
      twoFactorCode: '654321',
    );

    expect(repo.lastTwoFactorCode, '654321');
  });
}
