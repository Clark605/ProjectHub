import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/features/dashboard/data/models/activity_filter.dart';
import 'package:client/features/dashboard/ui/widgets/activity_filter_bottom_sheet.dart';

void main() {
  group('ActivityFilterBottomSheet Widget Tests', () {
    testWidgets(
      'renders on mobile viewport (< 768px) with 48px touch targets and applies selections',
      (tester) async {
        // Configure standard mobile viewport: 390x844 (iPhone / modern Android)
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        ActivityFilter? appliedFilter;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    ActivityFilterBottomSheet.show(
                      context,
                      initialFilter: const ActivityFilter.empty(),
                      onApply: (f) => appliedFilter = f,
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        // Open bottom sheet
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.text('Filter & Sort'), findsOneWidget);
        expect(find.text('Category'), findsOneWidget);
        expect(find.text('Sort By'), findsOneWidget);

        // Verify Apply button touch target height is at least 48px
        final applyButtonSize = tester.getSize(find.widgetWithText(ElevatedButton, 'Apply Filters'));
        expect(applyButtonSize.height, greaterThanOrEqualTo(48.0));

        // Select 'Projects' category
        await tester.tap(find.widgetWithText(ChoiceChip, 'Projects'));
        await tester.pumpAndSettle();

        // Select 'Oldest first'
        await tester.tap(find.widgetWithText(ChoiceChip, 'Oldest first'));
        await tester.pumpAndSettle();

        // Tap Apply Filters
        await tester.tap(find.widgetWithText(ElevatedButton, 'Apply Filters'));
        await tester.pumpAndSettle();

        // Verify bottom sheet closed and callback received correct filter
        expect(find.text('Filter & Sort'), findsNothing);
        expect(appliedFilter, isNotNull);
        expect(appliedFilter!.category, 'Projects');
        expect(appliedFilter!.sortOrder, ActivitySortOrder.oldestFirst);
      },
    );

    testWidgets('Reset button clears selections', (tester) async {
      ActivityFilter? appliedFilter;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ActivityFilterBottomSheet.show(
                    context,
                    initialFilter: const ActivityFilter(
                      category: 'Tasks',
                      sortOrder: ActivitySortOrder.oldestFirst,
                    ),
                    onApply: (f) => appliedFilter = f,
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap Reset button
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      // Tap Apply
      await tester.tap(find.widgetWithText(ElevatedButton, 'Apply Filters'));
      await tester.pumpAndSettle();

      expect(appliedFilter, isNotNull);
      expect(appliedFilter!.category, 'All');
      expect(appliedFilter!.sortOrder, ActivitySortOrder.newestFirst);
    });
  });
}
