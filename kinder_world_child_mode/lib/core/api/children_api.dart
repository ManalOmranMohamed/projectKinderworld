import 'package:kinder_world/core/network/network_service.dart';

class ChildrenApi {
  const ChildrenApi(this._network);

  final NetworkService _network;

  Future<List<Map<String, dynamic>>> fetchChildren() async {
    final response = await _network.get<dynamic>('/children');
    return _extractChildrenList(response.data);
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

  List<Map<String, dynamic>> _extractChildrenList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    if (data is Map) {
      final listData =
          data['children'] ?? data['data'] ?? data['results'] ?? data['items'];
      if (listData is List) {
        return listData
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }
    return const [];
  }
}
