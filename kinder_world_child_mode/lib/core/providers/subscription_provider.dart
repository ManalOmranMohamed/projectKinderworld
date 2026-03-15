import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kinder_world/core/api/api_providers.dart';
import 'package:kinder_world/app.dart';
import 'package:kinder_world/core/providers/cache_provider.dart';
import 'package:kinder_world/core/services/subscription_service.dart';

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  final subscriptionApi = ref.watch(subscriptionApiProvider);
  final cacheStore = ref.watch(appCacheStoreProvider);
  final logger = ref.watch(loggerProvider);

  return SubscriptionService(
    subscriptionApi: subscriptionApi,
    cacheStore: cacheStore,
    logger: logger,
  );
});
