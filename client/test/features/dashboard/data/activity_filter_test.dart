import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/features/dashboard/data/models/activity_event_dto.dart';
import 'package:client/features/dashboard/data/models/activity_filter.dart';

void main() {
  group('ActivityFilter Tests', () {
    final now = DateTime(2026, 9, 22, 12, 0);

    final activities = [
      ActivityEventDto(
        id: 1,
        workspaceId: 10,
        actorId: 'u1',
        actorName: 'Alice',
        eventType: 'TaskCreated',
        metadata: {'Title': 'Implement Auth'},
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      ActivityEventDto(
        id: 2,
        workspaceId: 10,
        actorId: 'u2',
        actorName: 'Bob',
        eventType: 'ProjectCreated',
        metadata: {'Name': 'Mobile Redesign'},
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      ActivityEventDto(
        id: 3,
        workspaceId: 10,
        actorId: 'u3',
        actorName: 'Charlie',
        eventType: 'MemberAdded',
        metadata: {'MemberName': 'Dave', 'Role': 'Member'},
        createdAt: now,
      ),
    ];

    test('default filter returns all items newest first', () {
      const filter = ActivityFilter();
      final filtered = filter.apply(activities);

      expect(filtered.length, 3);
      expect(filtered.first.id, 3); // newest
      expect(filtered.last.id, 1); // oldest
      expect(filter.hasActiveFilters, isFalse);
    });

    test('filters by category Tasks', () {
      const filter = ActivityFilter(category: 'Tasks');
      final filtered = filter.apply(activities);

      expect(filtered.length, 1);
      expect(filtered.first.eventType, 'TaskCreated');
      expect(filter.hasActiveFilters, isTrue);
    });

    test('filters by category Projects', () {
      const filter = ActivityFilter(category: 'Projects');
      final filtered = filter.apply(activities);

      expect(filtered.length, 1);
      expect(filtered.first.eventType, 'ProjectCreated');
    });

    test('filters by category Members', () {
      const filter = ActivityFilter(category: 'Members');
      final filtered = filter.apply(activities);

      expect(filtered.length, 1);
      expect(filtered.first.eventType, 'MemberAdded');
    });

    test('filters by search keyword matching actor name', () {
      const filter = ActivityFilter(search: 'alice');
      final filtered = filter.apply(activities);

      expect(filtered.length, 1);
      expect(filtered.first.actorName, 'Alice');
    });

    test('filters by search keyword matching targetTitle', () {
      const filter = ActivityFilter(search: 'Auth');
      final filtered = filter.apply(activities);

      expect(filtered.length, 1);
      expect(filtered.first.targetTitle, 'Implement Auth');
    });

    test('sorts oldest first when requested', () {
      const filter = ActivityFilter(sortOrder: ActivitySortOrder.oldestFirst);
      final filtered = filter.apply(activities);

      expect(filtered.first.id, 1); // oldest
      expect(filtered.last.id, 3); // newest
      expect(filter.hasActiveFilters, isTrue);
    });

    test('filters by date range', () {
      final multiDayActivities = [
        ActivityEventDto(
          id: 1,
          workspaceId: 10,
          actorId: 'u1',
          actorName: 'Alice',
          eventType: 'TaskCreated',
          metadata: {'Title': 'Old Task'},
          createdAt: now.subtract(const Duration(days: 5)),
        ),
        ActivityEventDto(
          id: 2,
          workspaceId: 10,
          actorId: 'u2',
          actorName: 'Bob',
          eventType: 'ProjectCreated',
          metadata: {'Name': 'Mid Project'},
          createdAt: now.subtract(const Duration(days: 2)),
        ),
        ActivityEventDto(
          id: 3,
          workspaceId: 10,
          actorId: 'u3',
          actorName: 'Charlie',
          eventType: 'MemberAdded',
          metadata: {'MemberName': 'Dave'},
          createdAt: now,
        ),
      ];

      final range = DateTimeRange(
        start: now.subtract(const Duration(days: 3)),
        end: now,
      );
      final filter = ActivityFilter(dateRange: range);
      final filtered = filter.apply(multiDayActivities);

      expect(filtered.length, 2);
      expect(filtered.map((e) => e.id), containsAll([2, 3]));
      expect(filtered.map((e) => e.id), isNot(contains(1)));
    });

    test('toQueryParams serializes query options correctly', () {
      const filter = ActivityFilter(
        category: 'Tasks',
        search: 'urgent',
        sortOrder: ActivitySortOrder.oldestFirst,
      );

      final params = filter.toQueryParams(limit: 40);

      expect(params['limit'], 40);
      expect(params['eventType'], 'Task');
      expect(params['search'], 'urgent');
      expect(params['sortBy'], 'date');
      expect(params['sortDescending'], isFalse);
    });
  });
}
