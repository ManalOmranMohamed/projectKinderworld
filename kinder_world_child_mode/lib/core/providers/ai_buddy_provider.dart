import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kinder_world/app.dart';
import 'package:kinder_world/core/api/api_providers.dart';
import 'package:kinder_world/core/models/child_profile.dart';
import 'package:kinder_world/core/providers/child_session_controller.dart';
import 'package:kinder_world/core/services/ai_buddy_service.dart';

final aiBuddyServiceProvider = Provider<AiBuddyService>((ref) {
  final api = ref.watch(aiBuddyApiProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  final logger = ref.watch(loggerProvider);
  return AiBuddyService(
    api: api,
    secureStorage: secureStorage,
    logger: logger,
  );
});

final aiBuddyCurrentChildProvider = Provider<ChildProfile?>((ref) {
  return ref.watch(currentChildProvider);
});

final aiBuddyCurrentChildIdProvider = Provider<String?>((ref) {
  final childId = ref.watch(aiBuddyCurrentChildProvider)?.id.trim();
  if (childId != null && childId.isNotEmpty) {
    return childId;
  }

  return ref.watch(currentChildIdProvider);
});
