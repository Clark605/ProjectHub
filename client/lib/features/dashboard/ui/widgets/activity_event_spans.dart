import 'package:flutter/material.dart';

import 'package:client/features/dashboard/data/models/activity_event_dto.dart';
import 'package:client/features/tasks/data/models/task_status.dart';
import 'package:client/features/tasks/ui/extensions/task_status_ui.dart';
import 'package:client/l10n/generated/app_localizations.dart';

String _formatStatusName(String? status, AppLocalizations l10n) {
  if (status == null || status.isEmpty) return '';
  final cleaned = status.replaceAll('"', '').trim();
  final lower = cleaned
      .toLowerCase()
      .replaceAll(' ', '')
      .replaceAll('-', '')
      .replaceAll('_', '');

  if ([
    'backlog',
    'todo',
    'inprogress',
    'review',
    'inreview',
    'done',
  ].contains(lower)) {
    final taskStatus = TaskStatus.fromString(cleaned);
    return taskStatus.localizedName(l10n);
  }

  if (lower == 'inprogress') return 'In Progress';
  if (lower == 'todo') return 'To Do';
  if (lower == 'inreview') return 'In Review';
  return cleaned;
}

List<InlineSpan> buildActivityEventSpans(
  ActivityEventDto event,
  ThemeData theme,
  AppLocalizations l10n,
) {
  final mutedStyle = TextStyle(color: theme.colorScheme.onSurfaceVariant);
  final highlightStyle = TextStyle(
    color: theme.colorScheme.onSurface,
    fontWeight: FontWeight.w600,
  );
  final title = event.targetTitle?.replaceAll('"', '');
  final project = event.projectName?.replaceAll('"', '');

  switch (event.eventType) {
    case 'TaskCreated':
      final spans = <InlineSpan>[
        TextSpan(text: l10n.activityTaskCreated, style: mutedStyle),
        if (title != null && title.isNotEmpty) ...[
          const TextSpan(text: ' '),
          TextSpan(text: title, style: highlightStyle),
        ],
      ];
      _appendProjectContext(spans, project, l10n, mutedStyle, highlightStyle);
      return spans;

    case 'TaskUpdated':
      final spans = <InlineSpan>[
        TextSpan(text: l10n.activityTaskUpdated, style: mutedStyle),
        if (title != null && title.isNotEmpty) ...[
          const TextSpan(text: ' '),
          TextSpan(text: title, style: highlightStyle),
        ],
      ];
      _appendProjectContext(spans, project, l10n, mutedStyle, highlightStyle);
      return spans;

    case 'TaskStatusChanged':
      final toStatus = _formatStatusName(event.newStatus ?? event.status, l10n);
      final spans = <InlineSpan>[];
      if (title != null && title.isNotEmpty && toStatus.isNotEmpty) {
        final full = l10n.activityMovedTo(title, toStatus);
        spans.addAll(
          _buildParameterizedSpans(
            full,
            [title, toStatus],
            mutedStyle,
            highlightStyle,
          ),
        );
      } else if (toStatus.isNotEmpty) {
        final full = l10n.activityTaskMovedToStatus(toStatus);
        spans.addAll(
          _buildParameterizedSpans(
            full,
            [toStatus],
            mutedStyle,
            highlightStyle,
          ),
        );
      } else {
        spans.add(
          TextSpan(text: l10n.activityTaskStatusChanged, style: mutedStyle),
        );
      }
      _appendProjectContext(spans, project, l10n, mutedStyle, highlightStyle);
      return spans;

    case 'TaskAssigned':
      final assignee = event.assigneeName?.replaceAll('"', '');
      final spans = <InlineSpan>[];
      if (assignee != null && assignee.isNotEmpty) {
        if (title != null && title.isNotEmpty) {
          final full = l10n.activityAssignedTo(title, assignee);
          spans.addAll(
            _buildParameterizedSpans(
              full,
              [title, assignee],
              mutedStyle,
              highlightStyle,
            ),
          );
        } else {
          final full = l10n.activityAssignedTaskTo(assignee);
          spans.addAll(
            _buildParameterizedSpans(
              full,
              [assignee],
              mutedStyle,
              highlightStyle,
            ),
          );
        }
      } else {
        spans.add(TextSpan(text: l10n.activityTaskAssigned, style: mutedStyle));
        if (title != null && title.isNotEmpty) {
          spans.add(const TextSpan(text: ' '));
          spans.add(TextSpan(text: title, style: highlightStyle));
        }
      }
      _appendProjectContext(spans, project, l10n, mutedStyle, highlightStyle);
      return spans;

    case 'TaskDeleted':
      final spans = <InlineSpan>[
        TextSpan(text: l10n.activityTaskDeleted, style: mutedStyle),
        if (title != null && title.isNotEmpty) ...[
          const TextSpan(text: ' '),
          TextSpan(text: title, style: highlightStyle),
        ],
      ];
      _appendProjectContext(spans, project, l10n, mutedStyle, highlightStyle);
      return spans;

    case 'ProjectCreated':
      return [
        TextSpan(text: l10n.activityProjectCreated, style: mutedStyle),
        if (title != null && title.isNotEmpty) ...[
          const TextSpan(text: ' '),
          TextSpan(text: title, style: highlightStyle),
        ],
      ];

    case 'ProjectStatusChanged':
      final toStatus = _formatStatusName(event.newStatus ?? event.status, l10n);
      if (title != null && title.isNotEmpty && toStatus.isNotEmpty) {
        final full = l10n.activityUpdatedProjectTo(title, toStatus);
        return _buildParameterizedSpans(
          full,
          [title, toStatus],
          mutedStyle,
          highlightStyle,
        );
      } else {
        return [
          TextSpan(text: l10n.activityProjectStatusChanged, style: mutedStyle),
          if (toStatus.isNotEmpty) ...[
            const TextSpan(text: ' '),
            TextSpan(text: toStatus, style: highlightStyle),
          ],
        ];
      }

    case 'ProjectArchived':
      return [
        TextSpan(text: l10n.activityProjectArchived, style: mutedStyle),
        if (title != null && title.isNotEmpty) ...[
          const TextSpan(text: ' '),
          TextSpan(text: title, style: highlightStyle),
        ],
      ];

    case 'ProjectDeleted':
      return [
        TextSpan(text: l10n.activityProjectDeleted, style: mutedStyle),
        if (title != null && title.isNotEmpty) ...[
          const TextSpan(text: ' '),
          TextSpan(text: title, style: highlightStyle),
        ],
      ];

    case 'MemberAdded':
      final member = event.memberName?.replaceAll('"', '');
      final role = event.role;
      if (member != null && member.isNotEmpty) {
        if (role != null && role.isNotEmpty) {
          final full = l10n.activityAddedMemberAsRole(member, role);
          return _buildParameterizedSpans(
            full,
            [member, role],
            mutedStyle,
            highlightStyle,
          );
        } else {
          final full = l10n.activityAddedMemberToWorkspace(member);
          return _buildParameterizedSpans(
            full,
            [member],
            mutedStyle,
            highlightStyle,
          );
        }
      } else {
        return [TextSpan(text: l10n.activityMemberAdded, style: mutedStyle)];
      }

    case 'MemberRemoved':
      final member = event.memberName?.replaceAll('"', '');
      if (member != null && member.isNotEmpty) {
        final full = l10n.activityRemovedMemberFromWorkspace(member);
        return _buildParameterizedSpans(
          full,
          [member],
          mutedStyle,
          highlightStyle,
        );
      } else {
        return [TextSpan(text: l10n.activityMemberRemoved, style: mutedStyle)];
      }

    case 'WorkspaceCreated':
      return [TextSpan(text: l10n.activityWorkspaceCreated, style: mutedStyle)];

    case 'WorkspaceUpdated':
      if (title != null && title.isNotEmpty) {
        final full = l10n.activityRenamedWorkspaceTo(title);
        return _buildParameterizedSpans(
          full,
          [title],
          mutedStyle,
          highlightStyle,
        );
      } else {
        return [
          TextSpan(text: l10n.activityWorkspaceUpdated, style: mutedStyle),
        ];
      }

    default:
      if (title != null && title.isNotEmpty) {
        final full = l10n.activityPerformedEventOn(event.eventType, title);
        return _buildParameterizedSpans(
          full,
          [event.eventType, title],
          mutedStyle,
          highlightStyle,
        );
      } else {
        final full = l10n.activityPerformedEvent(event.eventType);
        return _buildParameterizedSpans(
          full,
          [event.eventType],
          mutedStyle,
          highlightStyle,
        );
      }
  }
}

void _appendProjectContext(
  List<InlineSpan> spans,
  String? project,
  AppLocalizations l10n,
  TextStyle mutedStyle,
  TextStyle highlightStyle,
) {
  if (project != null && project.isNotEmpty) {
    spans.add(const TextSpan(text: ' '));
    final full = l10n.activityInProject(project);
    spans.addAll(
      _buildParameterizedSpans(full, [project], mutedStyle, highlightStyle),
    );
  }
}

List<InlineSpan> _buildParameterizedSpans(
  String fullText,
  List<String> highlights,
  TextStyle mutedStyle,
  TextStyle highlightStyle,
) {
  final cleanText = fullText.replaceAll('"', '');
  if (highlights.isEmpty) {
    return [TextSpan(text: cleanText, style: mutedStyle)];
  }

  final cleanHighlights = highlights
      .map((h) => h.replaceAll('"', ''))
      .where((h) => h.isNotEmpty)
      .toList();

  final spans = <InlineSpan>[];
  var currentIndex = 0;

  while (currentIndex < cleanText.length) {
    int? earliestStart;
    String? earliestMatch;

    for (final h in cleanHighlights) {
      final idxPlain = cleanText.indexOf(h, currentIndex);
      if (idxPlain != -1 &&
          (earliestStart == null || idxPlain < earliestStart)) {
        earliestStart = idxPlain;
        earliestMatch = h;
      }
    }

    if (earliestStart != null && earliestMatch != null) {
      if (earliestStart > currentIndex) {
        spans.add(
          TextSpan(
            text: cleanText.substring(currentIndex, earliestStart),
            style: mutedStyle,
          ),
        );
      }
      spans.add(TextSpan(text: earliestMatch, style: highlightStyle));
      currentIndex = earliestStart + earliestMatch.length;
    } else {
      spans.add(
        TextSpan(text: cleanText.substring(currentIndex), style: mutedStyle),
      );
      break;
    }
  }

  return spans;
}
