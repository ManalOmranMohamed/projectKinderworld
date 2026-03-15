import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kinder_world/core/api/auth_api.dart';
import 'package:kinder_world/core/models/user.dart';
import 'package:kinder_world/core/network/network_service.dart';
import 'package:kinder_world/core/repositories/auth_repository.dart';
import 'package:kinder_world/core/storage/secure_storage.dart';
import 'package:logger/logger.dart';

class _MemorySecureStorage extends SecureStorage {
  String? authToken;
  String? refreshToken;
  String? userId;
  String? userEmail;
  String? userRole;
  String? childSession;
  bool parentPinVerified = false;

  @override
  Future<String?> getAuthToken() async => authToken;

  @override
  Future<bool> saveAuthToken(String token) async {
    authToken = token;
    return true;
  }

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<bool> saveRefreshToken(String token) async {
    refreshToken = token;
    return true;
  }

  @override
  Future<bool> deleteRefreshToken() async {
    refreshToken = null;
    return true;
  }

  @override
  Future<bool> saveUserId(String value) async {
    userId = value;
    return true;
  }

  @override
  Future<String?> getUserId() async => userId;

  @override
  Future<bool> saveUserEmail(String value) async {
    userEmail = value;
    return true;
  }

  @override
  Future<String?> getUserEmail() async => userEmail;

  @override
  Future<bool> deleteUserEmail() async {
    userEmail = null;
    return true;
  }

  @override
  Future<bool> saveUserRole(String value) async {
    userRole = value;
    return true;
  }

  @override
  Future<String?> getUserRole() async => userRole;

  @override
  Future<bool> saveChildSession(String childId) async {
    childSession = childId;
    return true;
  }

  @override
  Future<String?> getChildSession() async => childSession;

  @override
  Future<bool> clearChildSession() async {
    childSession = null;
    return true;
  }

  @override
  Future<bool> saveParentPinVerified(bool isVerified) async {
    parentPinVerified = isVerified;
    return true;
  }

  @override
  Future<bool> isParentPinVerified() async => parentPinVerified;

  @override
  Future<bool> clearParentPinVerification() async {
    parentPinVerified = false;
    return true;
  }

  @override
  Future<bool> clearAuthOnly() async {
    authToken = null;
    refreshToken = null;
    userId = null;
    userEmail = null;
    userRole = null;
    childSession = null;
    parentPinVerified = false;
    return true;
  }

  @override
  Future<bool> isAuthenticated() async =>
      authToken != null && authToken!.isNotEmpty;
}

class _FakeAuthApi extends AuthApi {
  _FakeAuthApi(this.storage)
      : super(
          NetworkService(
            secureStorage: storage,
            logger: Logger(),
          ),
        );

  final SecureStorage storage;
  AuthSessionPayload? loginPayload;
  AuthSessionPayload? registerPayload;
  ChildLoginPayload? childLoginPayload;
  Map<String, dynamic>? refreshPayload;

  @override
  Future<AuthSessionPayload> login({
    required String email,
    required String password,
  }) async {
    return loginPayload!;
  }

  @override
  Future<AuthSessionPayload> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    return registerPayload!;
  }

  @override
  Future<ChildLoginPayload> childLogin({
    required String childId,
    required String name,
    required List<String> picturePassword,
  }) async {
    return childLoginPayload!;
  }

  @override
  Future<Map<String, dynamic>> refresh({
    required String refreshToken,
  }) async {
    return refreshPayload ?? const {};
  }
}

String _jwtWithExp(DateTime dateTime) {
  final header = base64Url.encode(utf8.encode('{"alg":"none","typ":"JWT"}'));
  final payload = base64Url.encode(
    utf8.encode('{"exp":${dateTime.millisecondsSinceEpoch ~/ 1000}}'),
  );
  return '$header.$payload.signature';
}

Map<String, dynamic> _parentAuthRaw({
  required String accessToken,
  required String refreshToken,
}) {
  return {
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'user': {
      'id': 'parent-1',
      'email': 'parent@example.com',
      'role': UserRoles.parent,
      'name': 'Parent User',
      'created_at': '2025-01-01T00:00:00.000Z',
      'updated_at': '2025-01-01T00:00:00.000Z',
      'is_active': true,
    },
  };
}

void main() {
  late _MemorySecureStorage storage;
  late _FakeAuthApi authApi;
  late AuthRepository repository;

  setUp(() {
    storage = _MemorySecureStorage();
    authApi = _FakeAuthApi(storage);
    repository = AuthRepository(
      secureStorage: storage,
      authApi: authApi,
      logger: Logger(),
    );
  });

  test('loginParent persists parent auth and clears stale child session state',
      () async {
    storage.childSession = 'child-7';
    storage.parentPinVerified = true;
    authApi.loginPayload = AuthSessionPayload(
      accessToken: 'parent.jwt',
      refreshToken: 'refresh.jwt',
      user: Map<String, dynamic>.from(
        _parentAuthRaw(
          accessToken: 'parent.jwt',
          refreshToken: 'refresh.jwt',
        )['user'] as Map<String, dynamic>,
      ),
      raw: _parentAuthRaw(
        accessToken: 'parent.jwt',
        refreshToken: 'refresh.jwt',
      ),
    );

    final user = await repository.loginParent(
      email: 'Parent@Example.com',
      password: 'Password123!',
    );

    expect(user, isNotNull);
    expect(storage.authToken, 'parent.jwt');
    expect(storage.refreshToken, 'refresh.jwt');
    expect(storage.userRole, UserRoles.parent);
    expect(storage.userEmail, 'parent@example.com');
    expect(storage.childSession, isNull);
    expect(storage.parentPinVerified, isFalse);
  });

  test('loginChild clears parent-only fields and saves child session marker',
      () async {
    storage.refreshToken = 'refresh.jwt';
    storage.userEmail = 'parent@example.com';
    storage.parentPinVerified = true;
    authApi.childLoginPayload = const ChildLoginPayload(
      success: true,
      childId: 'child-7',
      name: 'Mira',
      raw: {
        'name': 'Mira',
        'child_id': 'child-7',
      },
    );

    final user = await repository.loginChild(
      childId: 'child-7',
      childName: 'Mira',
      picturePassword: const ['apple', 'cat', 'dog'],
    );

    expect(user, isNotNull);
    expect(storage.authToken, 'child_session_child-7');
    expect(storage.refreshToken, isNull);
    expect(storage.userEmail, isNull);
    expect(storage.userRole, UserRoles.child);
    expect(storage.userId, 'child-7');
    expect(storage.childSession, 'child-7');
    expect(storage.parentPinVerified, isFalse);
  });

  test('validateToken returns false for expired jwt and true for child marker',
      () async {
    storage.authToken = _jwtWithExp(
      DateTime.now().toUtc().subtract(const Duration(minutes: 5)),
    );
    expect(await repository.validateToken(), isFalse);

    storage.authToken = 'child_session_child-7';
    expect(await repository.validateToken(), isTrue);
  });

  test('logout clears auth-only session fields', () async {
    storage.authToken = 'token';
    storage.refreshToken = 'refresh';
    storage.userId = 'parent-1';
    storage.userEmail = 'parent@example.com';
    storage.userRole = UserRoles.parent;
    storage.childSession = 'child-1';
    storage.parentPinVerified = true;

    final success = await repository.logout();

    expect(success, isTrue);
    expect(storage.authToken, isNull);
    expect(storage.refreshToken, isNull);
    expect(storage.userId, isNull);
    expect(storage.userEmail, isNull);
    expect(storage.userRole, isNull);
    expect(storage.childSession, isNull);
    expect(storage.parentPinVerified, isFalse);
  });
}
