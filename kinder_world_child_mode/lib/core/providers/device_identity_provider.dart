import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kinder_world/core/providers/shared_preferences_provider.dart';
import 'package:kinder_world/core/services/device_identity_service.dart';

final deviceIdentityServiceProvider = Provider<DeviceIdentityService>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return DeviceIdentityService(sharedPreferences: sharedPreferences);
});
