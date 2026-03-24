import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinder_world/core/providers/sync_status_provider.dart';
import 'package:kinder_world/core/widgets/app_connection_status.dart';
import 'package:kinder_world/core/widgets/app_skeleton_widgets.dart';

import 'support/test_harness.dart';

void main() {
  group('App feedback widgets', () {
    testWidgets('offline banner explains queued sync behavior',
        (WidgetTester tester) async {
      final harness = await TestHarness.create();

      await harness.pumpApp(
        tester,
        overrides: [
          syncStatusProvider.overrideWith(
            (ref) => SyncStatusController(
              const AppSyncStatus(isOffline: true),
            ),
          ),
        ],
        home: const Scaffold(
          body: AppConnectionStatusBanner.parent(),
        ),
      );

      expect(find.text('Offline Mode'), findsOneWidget);
      expect(
        find.text('Some actions will sync when you reconnect.'),
        findsOneWidget,
      );
    });

    testWidgets('sync banner shows progress state',
        (WidgetTester tester) async {
      final harness = await TestHarness.create();

      await harness.pumpApp(
        tester,
        overrides: [
          syncStatusProvider.overrideWith(
            (ref) => SyncStatusController(
              const AppSyncStatus(isSyncing: true),
            ),
          ),
        ],
        home: const Scaffold(
          body: AppConnectionStatusBanner.child(),
        ),
      );

      expect(find.text('Syncing your latest changes'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('admin overview skeleton renders placeholder blocks',
        (WidgetTester tester) async {
      final harness = await TestHarness.create();

      await harness.pumpApp(
        tester,
        home: const Scaffold(
          body: SingleChildScrollView(
            child: AdminOverviewSkeleton(),
          ),
        ),
      );

      expect(find.byType(AppSkeletonBox), findsWidgets);
    });
  });
}
