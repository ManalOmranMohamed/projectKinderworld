import 'package:kinder_world/core/network/network_service.dart';

class AuthSessionPayload {
  const AuthSessionPayload({
    required this.accessToken,
    required this.user,
    this.refreshToken,
    required this.raw,
  });

  final String accessToken;
  final String? refreshToken;
  final Map<String, dynamic> user;
  final Map<String, dynamic> raw;
}

class ChildLoginPayload {
  const ChildLoginPayload({
    required this.success,
    this.childId,
    this.name,
    required this.raw,
  });

  final bool success;
  final String? childId;
  final String? name;
  final Map<String, dynamic> raw;
}

class AuthApi {
  const AuthApi(this._network);

  final NetworkService _network;

  Future<AuthSessionPayload> login({
    required String email,
    required String password,
  }) async {
    final response = await _network.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );
    return _toSessionPayload(response.data);
  }

  Future<AuthSessionPayload> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await _network.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'name': name,
        'email': email.trim().toLowerCase(),
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );
    return _toSessionPayload(response.data);
  }

  Future<Map<String, dynamic>> refresh({
    required String refreshToken,
  }) async {
    final response = await _network.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );
    return Map<String, dynamic>.from(response.data ?? const {});
  }

  Future<Map<String, dynamic>> me() async {
    final response = await _network.get<Map<String, dynamic>>('/auth/me');
    return Map<String, dynamic>.from(response.data ?? const {});
  }

  Future<Map<String, dynamic>> logout() async {
    final response = await _network.post<Map<String, dynamic>>('/auth/logout');
    return Map<String, dynamic>.from(response.data ?? const {});
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
  }) async {
    final response = await _network.put<Map<String, dynamic>>(
      '/auth/profile',
      data: {'name': name.trim()},
    );
    return Map<String, dynamic>.from(response.data ?? const {});
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await _network.post<Map<String, dynamic>>(
      '/auth/change-password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
    return Map<String, dynamic>.from(response.data ?? const {});
  }

  Future<ChildLoginPayload> childLogin({
    required String childId,
    required String name,
    required List<String> picturePassword,
  }) async {
    final response = await _network.post<Map<String, dynamic>>(
      '/auth/child/login',
      data: {
        'child_id': int.tryParse(childId) ?? childId,
        'name': name.trim(),
        'picture_password': picturePassword,
      },
    );
    final body = Map<String, dynamic>.from(response.data ?? const {});
    return ChildLoginPayload(
      success: body['success'] == true,
      childId: body['child_id']?.toString(),
      name: body['name']?.toString(),
      raw: body,
    );
  }

  Future<Map<String, dynamic>> childRegister({
    required String name,
    required List<String> picturePassword,
    required String parentEmail,
    required int age,
    String? avatar,
  }) async {
    final response = await _network.post<Map<String, dynamic>>(
      '/auth/child/register',
      data: {
        'name': name.trim(),
        'picture_password': picturePassword,
        'parent_email': parentEmail.trim().toLowerCase(),
        'age': age,
        if (avatar != null) 'avatar': avatar,
      },
    );
    return Map<String, dynamic>.from(response.data ?? const {});
  }

  Future<Map<String, dynamic>> childChangePassword({
    required String childId,
    required String name,
    required List<String> currentPicturePassword,
    required List<String> newPicturePassword,
  }) async {
    final response = await _network.post<Map<String, dynamic>>(
      '/auth/child/change-password',
      data: {
        'child_id': int.tryParse(childId) ?? childId,
        'name': name.trim(),
        'current_picture_password': currentPicturePassword,
        'new_picture_password': newPicturePassword,
      },
    );
    return Map<String, dynamic>.from(response.data ?? const {});
  }

  Future<Map<String, dynamic>> parentPinStatus() async {
    final response =
        await _network.get<Map<String, dynamic>>('/auth/parent-pin/status');
    return Map<String, dynamic>.from(response.data ?? const {});
  }

  Future<Map<String, dynamic>> parentPinSet({
    required String pin,
    required String confirmPin,
  }) async {
    final response = await _network.post<Map<String, dynamic>>(
      '/auth/parent-pin/set',
      data: {'pin': pin, 'confirm_pin': confirmPin},
    );
    return Map<String, dynamic>.from(response.data ?? const {});
  }

  Future<Map<String, dynamic>> parentPinVerify({
    required String pin,
  }) async {
    final response = await _network.post<Map<String, dynamic>>(
      '/auth/parent-pin/verify',
      data: {'pin': pin},
    );
    return Map<String, dynamic>.from(response.data ?? const {});
  }

  Future<Map<String, dynamic>> parentPinChange({
    required String currentPin,
    required String newPin,
    required String confirmPin,
  }) async {
    final response = await _network.post<Map<String, dynamic>>(
      '/auth/parent-pin/change',
      data: {
        'current_pin': currentPin,
        'new_pin': newPin,
        'confirm_pin': confirmPin,
      },
    );
    return Map<String, dynamic>.from(response.data ?? const {});
  }

  Future<Map<String, dynamic>> parentPinResetRequest({String? note}) async {
    final response = await _network.post<Map<String, dynamic>>(
      '/auth/parent-pin/reset-request',
      data: {if (note != null) 'note': note},
    );
    return Map<String, dynamic>.from(response.data ?? const {});
  }

  AuthSessionPayload _toSessionPayload(Map<String, dynamic>? data) {
    final body = Map<String, dynamic>.from(data ?? const {});
    return AuthSessionPayload(
      accessToken: body['access_token']?.toString() ?? '',
      refreshToken: body['refresh_token']?.toString(),
      user: Map<String, dynamic>.from(
        body['user'] as Map? ?? const <String, dynamic>{},
      ),
      raw: body,
    );
  }
}
