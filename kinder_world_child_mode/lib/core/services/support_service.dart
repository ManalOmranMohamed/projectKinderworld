import 'package:kinder_world/core/network/network_service.dart';
import 'package:logger/logger.dart';

class SupportService {
  final NetworkService _networkService;
  final Logger _logger;

  SupportService({
    required NetworkService networkService,
    required Logger logger,
  })  : _networkService = networkService,
        _logger = logger;

  Future<bool> sendContactMessage({
    required String subject,
    required String message,
  }) async {
    try {
      await _networkService.post<Map<String, dynamic>>(
        '/support/contact',
        data: {
          'subject': subject.trim(),
          'message': message.trim(),
        },
      );
      return true;
    } catch (e) {
      _logger.e('Error sending contact message: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getFaq() async {
    try {
      final response = await _networkService.get<List<dynamic>>(
        '/support/faq',
      );

      if (response.data == null) {
        return [];
      }

      return (response.data as List)
          .map<Map<String, dynamic>>(
            (e) => e is Map<String, dynamic> ? e : {},
          )
          .toList();
    } catch (e) {
      _logger.e('Error getting FAQ: $e');
      return [];
    }
  }
}
