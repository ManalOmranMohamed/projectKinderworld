import 'package:kinder_world/core/network/network_service.dart';
import 'package:kinder_world/core/utils/children_api_parsing.dart';

class ChildrenApi {
  const ChildrenApi(this._network);

  final NetworkService _network;

  Future<List<Map<String, dynamic>>> fetchChildren() async {
    final response = await _network.get<dynamic>('/children');
    return extractChildrenList(response.data);
  }

  Future<Map<String, dynamic>> createChild({
    required String name,
    required int age,
    String? avatar,
    String? parentEmail,
    List<String>? picturePassword,
  }) async {
    final response = await _network.post<Map<String, dynamic>>(
      '/children',
      data: {
        'name': name.trim(),
        'age': age,
        if (avatar != null) 'avatar': avatar,
        if (parentEmail != null)
          'parent_email': parentEmail.trim().toLowerCase(),
        if (picturePassword != null) 'picture_password': picturePassword,
      },
    );
    return Map<String, dynamic>.from(response.data ?? const {});
  }

  Future<Map<String, dynamic>> createChildFromPayload(
    Map<String, dynamic> payload,
  ) async {
    final response = await _network.post<Map<String, dynamic>>(
      '/children',
      data: payload,
    );
    return Map<String, dynamic>.from(response.data ?? const {});
  }

  Future<Map<String, dynamic>> updateChild({
    required String childId,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _network.put<Map<String, dynamic>>(
      '/children/${int.tryParse(childId) ?? childId}',
      data: payload,
    );
    return Map<String, dynamic>.from(response.data ?? const {});
  }

  Future<Map<String, dynamic>> deleteChild(String childId) async {
    final response = await _network.delete<Map<String, dynamic>>(
      '/children/${int.tryParse(childId) ?? childId}',
    );
    return Map<String, dynamic>.from(response.data ?? const {});
  }
}
