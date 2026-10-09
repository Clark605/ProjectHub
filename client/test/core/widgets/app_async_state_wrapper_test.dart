import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/core/widgets/app_async_state_wrapper.dart';
import 'package:client/core/widgets/app_empty_state.dart';
import 'package:client/core/widgets/app_error_state.dart';
import 'package:client/l10n/generated/app_localizations.dart';

void main() {
  Widget buildTestApp(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  group('AppAsyncStateWrapper', () {
    testWidgets('renders content child when there is no error and not empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          AppAsyncStateWrapper(
            onRefresh: () async {},
            child: const Text('Loaded Content'),
          ),
        ),
      );

      expect(find.text('Loaded Content'), findsOneWidget);
      expect(find.byType(AppErrorState), findsNothing);
      expect(find.byType(AppEmptyState), findsNothing);
    });

    testWidgets('renders AppErrorState when errorMessage is present', (
      tester,
    ) async {
      var refreshCalled = false;

      await tester.pumpWidget(
        buildTestApp(
          AppAsyncStateWrapper(
            errorMessage: 'Failed to load data',
            onRefresh: () async {
              refreshCalled = true;
            },
            child: const Text('Loaded Content'),
          ),
        ),
      );

      expect(find.text('Failed to load data'), findsOneWidget);
      expect(find.byType(AppErrorState), findsOneWidget);
      expect(find.text('Loaded Content'), findsNothing);

      // Tap retry button in AppErrorState
      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(refreshCalled, isTrue);
    });

    testWidgets('renders AppEmptyState when isEmpty is true with emptyTitle', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestApp(
          AppAsyncStateWrapper(
            isEmpty: true,
            emptyTitle: 'No items found',
            emptyDescription: 'Create a new project to get started',
            onRefresh: () async {},
            child: const Text('Loaded Content'),
          ),
        ),
      );

      expect(find.text('No items found'), findsOneWidget);
      expect(find.text('Create a new project to get started'), findsOneWidget);
      expect(find.byType(AppEmptyState), findsOneWidget);
      expect(find.text('Loaded Content'), findsNothing);
    });
  });
}
