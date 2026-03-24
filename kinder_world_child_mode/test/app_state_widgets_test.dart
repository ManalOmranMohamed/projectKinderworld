import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinder_world/core/widgets/app_state_widgets.dart';

import 'support/test_harness.dart';

void main() {
  group('App state widgets', () {
    testWidgets('child empty state renders content and action',
        (WidgetTester tester) async {
      final harness = await TestHarness.create();
      var tapped = false;

      await harness.pumpApp(
        tester,
        home: Scaffold(
          body: AppEmptyState.child(
            title: 'No payment methods',
            subtitle: 'Add one to continue',
            actionLabel: 'Add method',
            action: () => tapped = true,
          ),
        ),
      );

      expect(find.text('No payment methods'), findsOneWidget);
      expect(find.text('Add one to continue'), findsOneWidget);

      await tester.tap(find.text('Add method'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('parent error state uses retry callback',
        (WidgetTester tester) async {
      final harness = await TestHarness.create();
      var retried = false;

      await harness.pumpApp(
        tester,
        home: Scaffold(
          body: AppErrorState.parent(
            message: 'Network failed',
            onRetry: () => retried = true,
          ),
        ),
      );

      expect(find.text('Network failed'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retried, isTrue);
    });

    testWidgets('admin loading state shows localized loading label',
        (WidgetTester tester) async {
      final harness = await TestHarness.create();

      await harness.pumpApp(
        tester,
        home: const Scaffold(
          body: AppLoadingState.admin(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
    });
  });
}
