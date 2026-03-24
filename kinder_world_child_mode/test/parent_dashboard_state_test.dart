import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kinder_world/app.dart';
import 'package:kinder_world/core/localization/app_localizations.dart';
import 'package:kinder_world/core/models/child_profile.dart';
import 'package:kinder_world/core/models/progress_record.dart';
import 'package:kinder_world/core/network/network_service.dart';
import 'package:kinder_world/core/providers/child_session_controller.dart';
import 'package:kinder_world/core/providers/progress_controller.dart';
import 'package:kinder_world/core/repositories/child_repository.dart';
import 'package:kinder_world/core/repositories/progress_repository.dart';
import 'package:kinder_world/core/subscription/plan_info.dart';
import 'package:kinder_world/features/parent_mode/dashboard/parent_dashboard_screen.dart';
import 'package:logger/logger.dart';
import 'support/test_harness.dart';

class _DummyBox implements Box<dynamic> {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MemoryChildRepository extends ChildRepository {
  _MemoryChildRepository()
      : super(
          childBox: _DummyBox(),
          logger: Logger(),
        );

  final Map<String, ChildProfile> profiles = <String, ChildProfile>{};

  @override
  Future<List<ChildProfile>> getChildProfilesForParent(String parentId) async {
    return profiles.values
        .where((child) => child.parentId == parentId)
        .toList(growable: false);
  }

  @override
  Future<ChildProfile?> createChildProfile(ChildProfile profile) async {
    profiles[profile.id] = profile;
    return profile;
  }

  @override
  Future<void> linkChildrenToParent({
    required String parentId,
    required String parentEmail,
  }) async {}
}

class _MemoryProgressRepository extends ProgressRepository {
  _MemoryProgressRepository()
      : super(
          progressBox: _DummyBox(),
          logger: Logger(),
        );

  final List<ProgressRecord> records = <ProgressRecord>[];

  @override
  Future<List<ProgressRecord>> getProgressForChildren(
    Iterable<String> childIds,
  ) async {
    final ids = childIds.toSet();
    return records
        .where((record) => ids.contains(record.childId))
        .toList(growable: false);
  }
}

class _FailingNetworkService extends NetworkService {
  _FailingNetworkService({required super.secureStorage})
      : super(
          logger: Logger(),
        );

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    throw DioException(
      requestOptions: RequestOptions(path: path),
      response: Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 500,
        data: {'message': 'sync failed'},
      ),
    );
  }
}

ChildProfile _child({
  required String id,
  required String parentId,
  required String name,
}) {
  final now = DateTime.now();
  return ChildProfile(
    id: id,
    name: name,
    age: 8,
    avatar: 'assets/images/avatars/av1.png',
    avatarPath: 'assets/images/avatars/av1.png',
    interests: const [],
    level: 1,
    xp: 100,
    streak: 2,
    favorites: const [],
    parentId: parentId,
    parentEmail: 'parent@example.com',
    picturePassword: const ['apple', 'cat', 'dog'],
    createdAt: now,
    updatedAt: now,
    lastSession: now.subtract(const Duration(days: 1)),
    totalTimeSpent: 10,
    activitiesCompleted: 2,
    currentMood: null,
    learningStyle: null,
    specialNeeds: null,
    accessibilityNeeds: null,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MemoryChildRepository childRepository;
  late _MemoryProgressRepository progressRepository;

  setUp(() async {
    childRepository = _MemoryChildRepository();
    progressRepository = _MemoryProgressRepository();
  });

  testWidgets(
      'keeps local children visible when background sync fails for parent session',
      (tester) async {
    await childRepository.createChildProfile(
      _child(id: 'child-1', parentId: 'parent-1', name: 'Mira'),
    );
    final storage = TestSecureStorage(
      userId: 'parent-1',
      userEmail: 'parent@example.com',
      authToken: 'parent-token',
    );
    final harness = await TestHarness.create(
      secureStorage: storage,
      planInfoState: AsyncData(PlanInfo.fromTier(PlanTier.free)),
      overrides: [
        childRepositoryProvider.overrideWithValue(childRepository),
        progressRepositoryProvider.overrideWithValue(progressRepository),
        networkServiceProvider.overrideWithValue(
          _FailingNetworkService(secureStorage: storage),
        ),
      ],
    );

    await harness.pumpApp(
      tester,
      home: const ParentDashboardScreen(),
      surfaceSize: const Size(1400, 2400),
      settleDuration: const Duration(milliseconds: 600),
    );

    final l10n = AppLocalizations.of(
        tester.element(find.byType(ParentDashboardScreen)))!;
    expect(find.text('Mira'), findsOneWidget);
    expect(find.text(l10n.addChild), findsOneWidget);
  });

  testWidgets('shows empty children state when parent has no child profiles',
      (tester) async {
    final storage = TestSecureStorage(
      userId: 'parent-1',
      userEmail: 'parent@example.com',
    );
    final harness = await TestHarness.create(
      secureStorage: storage,
      planInfoState: AsyncData(PlanInfo.fromTier(PlanTier.free)),
      overrides: [
        childRepositoryProvider.overrideWithValue(childRepository),
        progressRepositoryProvider.overrideWithValue(progressRepository),
      ],
    );

    await harness.pumpApp(
      tester,
      home: const ParentDashboardScreen(),
      surfaceSize: const Size(1400, 2400),
      settleDuration: const Duration(milliseconds: 600),
    );

    final l10n = AppLocalizations.of(
        tester.element(find.byType(ParentDashboardScreen)))!;
    expect(find.text(l10n.noChildrenAddedTitle), findsOneWidget);
    expect(find.text(l10n.addChild), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });
}
