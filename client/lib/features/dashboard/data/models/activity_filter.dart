import 'package:flutter/material.dart';
import 'package:client/features/dashboard/data/models/activity_event_dto.dart';

enum ActivitySortOrder {
  newestFirst,
  oldestFirst,
}

/// Pure filtering and sorting utility for workspace activity stream.
class ActivityFilter {
  final String category;
  final String? eventType;
  final String? search;
  final ActivitySortOrder sortOrder;
  final DateTimeRange? dateRange;

  const ActivityFilter({
    this.category = 'All',
    this.eventType,
    this.search,
    this.sortOrder = ActivitySortOrder.newestFirst,
    this.dateRange,
  });

  const ActivityFilter.empty()
      : category = 'All',
        eventType = null,
        search = null,
        sortOrder = ActivitySortOrder.newestFirst,
        dateRange = null;

  bool get hasActiveFilters =>
      category != 'All' ||
      (eventType != null && eventType!.isNotEmpty) ||
      (search != null && search!.trim().isNotEmpty) ||
      sortOrder != ActivitySortOrder.newestFirst ||
      dateRange != null;

  ActivityFilter copyWith({
    String? category,
    String? eventType,
    String? search,
    ActivitySortOrder? sortOrder,
    DateTimeRange? dateRange,
    bool clearDateRange = false,
  }) {
    return ActivityFilter(
      category: category ?? this.category,
      eventType: eventType ?? this.eventType,
      search: search ?? this.search,
      sortOrder: sortOrder ?? this.sortOrder,
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
    );
  }

  /// Pure client-side filtering and sorting for instant evaluation.
  List<ActivityEventDto> apply(List<ActivityEventDto> items) {
    final result = items.where((activity) {
      // Category filter
      if (category != 'All') {
        final normCategory = category.toLowerCase();
        final type = activity.eventType.toLowerCase();
        if (normCategory.startsWith('task') && !type.contains('task')) {
          return false;
        } else if (normCategory.startsWith('project') &&
            !type.contains('project')) {
          return false;
        } else if (normCategory.startsWith('member') &&
            !type.contains('member')) {
          return false;
        } else if (normCategory.startsWith('workspace') &&
            !type.contains('workspace')) {
          return false;
        }
      }

      // Exact eventType filter
      if (eventType != null && eventType!.isNotEmpty) {
        if (!activity.eventType
            .toLowerCase()
            .contains(eventType!.toLowerCase())) {
          return false;
        }
      }

      // Search keyword filter (actor name or target title)
      if (search != null && search!.trim().isNotEmpty) {
        final query = search!.trim().toLowerCase();
        final actor = activity.actorName.toLowerCase();
        final target = activity.targetTitle?.toLowerCase() ?? '';
        final member = activity.memberName?.toLowerCase() ?? '';
        final assignee = activity.assigneeName?.toLowerCase() ?? '';

        final matches = actor.contains(query) ||
            target.contains(query) ||
            member.contains(query) ||
            assignee.contains(query);

        if (!matches) return false;
      }

      // Date range filter
      if (dateRange != null) {
        final start = DateTime(
          dateRange!.start.year,
          dateRange!.start.month,
          dateRange!.start.day,
        );
        final end = DateTime(
          dateRange!.end.year,
          dateRange!.end.month,
          dateRange!.end.day,
          23,
          59,
          59,
        );
        if (activity.createdAt.isBefore(start) ||
            activity.createdAt.isAfter(end)) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sort order
    result.sort((a, b) {
      if (sortOrder == ActivitySortOrder.newestFirst) {
        return b.createdAt.compareTo(a.createdAt);
      } else {
        return a.createdAt.compareTo(b.createdAt);
      }
    });

    return result;
  }

  /// Converts active filter to HTTP query parameters.
  Map<String, dynamic> toQueryParams({int limit = 50}) {
    final params = <String, dynamic>{
      'limit': limit,
    };

    if (category != 'All') {
      // Map category to prefix/type
      if (category.toLowerCase().startsWith('task')) {
        params['eventType'] = 'Task';
      } else if (category.toLowerCase().startsWith('project')) {
        params['eventType'] = 'Project';
      } else if (category.toLowerCase().startsWith('member')) {
        params['eventType'] = 'Member';
      } else if (category.toLowerCase().startsWith('workspace')) {
        params['eventType'] = 'Workspace';
      }
    }

    if (eventType != null && eventType!.isNotEmpty) {
      params['eventType'] = eventType;
    }

    if (search != null && search!.trim().isNotEmpty) {
      params['search'] = search!.trim();
    }

    params['sortBy'] = 'date';
    params['sortDescending'] = sortOrder == ActivitySortOrder.newestFirst;

    if (dateRange != null) {
      params['startDate'] = dateRange!.start.toIso8601String();
      params['endDate'] = dateRange!.end.toIso8601String();
    }

    return params;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityFilter &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          eventType == other.eventType &&
          search == other.search &&
          sortOrder == other.sortOrder &&
          dateRange == other.dateRange;

  @override
  int get hashCode =>
      category.hashCode ^
      eventType.hashCode ^
      search.hashCode ^
      sortOrder.hashCode ^
      dateRange.hashCode;
}
