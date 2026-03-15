import 'package:kinder_world/core/network/network_service.dart';

class ReportsApi {
  const ReportsApi(this._network);

  final NetworkService _network;

  Future<Map<String, dynamic>> getBasicReports() async {
    final response = await _network.get<Map<String, dynamic>>('/reports/basic');
    return Map<String, dynamic>.from(response.data ?? const {});
  }

  Future<Map<String, dynamic>> getAdvancedReports() async {
    final response =
        await _network.get<Map<String, dynamic>>('/reports/advanced');
    return Map<String, dynamic>.from(response.data ?? const {});
  }

  Future<Map<String, dynamic>> ingestActivityEvent(
    Map<String, dynamic> payload,
  ) async {
    final response = await _network.post<Map<String, dynamic>>(
      '/analytics/events',
      data: payload,
    );
    return Map<String, dynamic>.from(response.data ?? const {});
  }

  Future<Map<String, dynamic>> ingestSessionLog(
    Map<String, dynamic> payload,
  ) async {
    final response = await _network.post<Map<String, dynamic>>(
      '/analytics/sessions',
      data: payload,
    );
    return Map<String, dynamic>.from(response.data ?? const {});
  }
}
