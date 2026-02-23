import 'package:kinder_world/core/network/network_service.dart';
import 'package:kinder_world/core/models/faq_item.dart';
import 'package:logger/logger.dart';

class ContentService {
  final NetworkService _networkService;
  final Logger _logger;

  ContentService({
    required NetworkService networkService,
    required Logger logger,
  })  : _networkService = networkService,
        _logger = logger;

  /// Get FAQ items (returns empty list if no API or error)
  Future<List<FaqItem>> getFaq() async {
    try {
      final response = await _networkService.get<List<dynamic>>(
        '/support/faq',
      );

      if (response.data == null || response.data!.isEmpty) {
        return [];
      }

      return (response.data as List)
          .map((e) {
            try {
              return FaqItem.fromJson(e as Map<String, dynamic>);
            } catch (_) {
              return null;
            }
          })
          .whereType<FaqItem>()
          .toList();
    } catch (e) {
      _logger.w('Error getting FAQ: $e');
      return [];
    }
  }

  /// Get legal content (returns empty string if no API or error)
  /// type can be: 'terms', 'privacy', 'coppa'
  Future<String> getLegal(String type) async {
    try {
      final response = await _networkService.get<Map<String, dynamic>>(
        '/content/legal?type=$type',
      );

      if (response.data == null) {
        return '';
      }

      return response.data!['content'] as String? ?? '';
    } catch (e) {
      _logger.w('Error getting legal content: $e');
      return '';
    }
  }
}
