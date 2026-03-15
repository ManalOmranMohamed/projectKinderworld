import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kinder_world/core/cache/app_cache_store.dart';
import 'package:kinder_world/core/providers/shared_preferences_provider.dart';

final appCacheStoreProvider = Provider<AppCacheStore>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AppCacheStore(prefs);
});
