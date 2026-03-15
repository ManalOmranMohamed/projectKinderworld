List<Map<String, dynamic>> extractChildrenList(dynamic data) {
  if (data is List) {
    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }
  if (data is Map) {
    final listData =
        data['children'] ?? data['data'] ?? data['results'] ?? data['items'];
    if (listData is List) {
      return listData
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }
  }
  return const [];
}

String? parseChildId(Map<String, dynamic> data) {
  final raw = data['id'] ?? data['child_id'] ?? data['childId'];
  return raw?.toString();
}
