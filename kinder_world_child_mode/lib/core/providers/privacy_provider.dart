import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kinder_world/core/models/privacy_settings.dart';
import 'package:kinder_world/core/services/privacy_service.dart';
import 'package:kinder_world/app.dart';

// Privacy settings provider
final privacyProvider =
    FutureProvider.autoDispose<PrivacySettings>((ref) async {
  final service = ref.watch(privacyServiceProvider);
  return service.getPrivacySettings();
});

// Privacy controller for updates
final privacyControllerProvider = StateNotifierProvider.autoDispose<
    PrivacyController, AsyncValue<PrivacySettings>>(
  (ref) {
    final service = ref.watch(privacyServiceProvider);
    return PrivacyController(service: service);
  },
);

class PrivacyController extends StateNotifier<AsyncValue<PrivacySettings>> {
  final PrivacyService _service;

  PrivacyController({
    required PrivacyService service,
  })  : _service = service,
        super(const AsyncValue.loading());

  Future<void> loadSettings() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.getPrivacySettings());
  }

  Future<bool> updateSettings(PrivacySettings settings) async {
    // Optimistic update
    state = AsyncValue.data(settings);

    try {
      final updated = await _service.updatePrivacySettings(settings);
      if (updated != null) {
        state = AsyncValue.data(updated);
        return true;
      } else {
        // Rollback on error
        final current = await _service.getPrivacySettings();
        state = AsyncValue.data(current);
        return false;
      }
    } catch (e) {
      // Rollback on error
      final current = await _service.getPrivacySettings();
      state = AsyncValue.data(current);
      return false;
    }
  }
}

// Service provider
final privacyServiceProvider = Provider<PrivacyService>((ref) {
  final networkService = ref.watch(networkServiceProvider);
  final logger = ref.watch(loggerProvider);
  return PrivacyService(
    networkService: networkService,
    logger: logger,
  );
});
