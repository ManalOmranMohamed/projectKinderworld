import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kinder_world/app.dart';
import 'package:kinder_world/core/offline/deferred_operations_queue.dart';
import 'package:kinder_world/core/providers/shared_preferences_provider.dart';

final deferredOperationsQueueProvider =
    Provider<DeferredOperationsQueue>((ref) {
  final preferences = ref.watch(sharedPreferencesProvider);
  final logger = ref.watch(loggerProvider);
  return DeferredOperationsQueue(
    preferences: preferences,
    logger: logger,
  );
});
