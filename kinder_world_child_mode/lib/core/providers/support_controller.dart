import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kinder_world/core/services/support_service.dart';
import 'package:kinder_world/app.dart';

// Support controller for sending messages
final supportControllerProvider =
    StateNotifierProvider.autoDispose<SupportController, AsyncValue<void>>(
  (ref) {
    final service = ref.watch(supportServiceProvider);
    return SupportController(service: service);
  },
);

class SupportController extends StateNotifier<AsyncValue<void>> {
  final SupportService _service;

  SupportController({required SupportService service})
      : _service = service,
        super(const AsyncValue.data(null));

  Future<bool> sendMessage({
    required String subject,
    required String message,
  }) async {
    state = const AsyncValue.loading();
    final success = await _service.sendContactMessage(
      subject: subject,
      message: message,
    );

    if (success) {
      state = const AsyncValue.data(null);
    } else {
      state = AsyncValue.error('Failed to send message', StackTrace.current);
    }

    return success;
  }
}

// Service provider
final supportServiceProvider = Provider<SupportService>((ref) {
  final networkService = ref.watch(networkServiceProvider);
  final logger = ref.watch(loggerProvider);
  return SupportService(
    networkService: networkService,
    logger: logger,
  );
});
