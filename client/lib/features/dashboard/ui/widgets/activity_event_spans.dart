import 'package:flutter/material.dart';

import 'package:client/features/dashboard/data/models/activity_event_dto.dart';
import 'package:client/features/tasks/data/models/task_status.dart';
import 'package:client/features/tasks/ui/extensions/task_status_ui.dart';
import 'package:client/l10n/generated/app_localizations.dart';

String _formatStatusName(String? status, AppLocalizations? l10n) {
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
    return l10n != null
        ? taskStatus.localizedName(l10n)
        : taskStatus.toDisplayString();
  }

  if (lower == 'inprogress') return 'In Progress';
  if (lower == 'todo') return 'To Do';
  if (lower == 'inreview') return 'In Review';
  return cleaned;
}

List<InlineSpan> buildActivityEventSpans(
  ActivityEventDto event,
  ThemeData theme,
  AppLocalizations? l10n,
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
        TextSpan(
          text: l10n?.activityTaskCreated ?? 'created task',
          style: mutedStyle,
        ),
        if (title != null && title.isNotEmpty) ...[
          const TextSpan(text: ' '),
          TextSpan(text: title, style: highlightStyle),
        ],
      ];
      _appendProjectContext(spans, project, l10n, mutedStyle, highlightStyle);
      return spans;

    case 'TaskUpdated':
      final spans = <InlineSpan>[
        TextSpan(
          text: l10n?.activityTaskUpdated ?? 'updated task',
          style: mutedStyle,
        ),
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
      if (l10n != null) {
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
      } else {
        if (title != null && title.isNotEmpty) {
          spans.add(TextSpan(text: 'moved ', style: mutedStyle));
          spans.add(TextSpan(text: title, style: highlightStyle));
          if (toStatus.isNotEmpty) {
            spans.add(TextSpan(text: ' to ', style: mutedStyle));
            spans.add(TextSpan(text: toStatus, style: highlightStyle));
          }
        } else {
          spans.add(TextSpan(text: 'updated task status', style: mutedStyle));
          if (toStatus.isNotEmpty) {
            spans.add(TextSpan(text: ' to ', style: mutedStyle));
            spans.add(TextSpan(text: toStatus, style: highlightStyle));
          }
        }
      }
      _appendProjectContext(spans, project, l10n, mutedStyle, highlightStyle);
      return spans;

    case 'TaskAssigned':
      final assignee = event.assigneeName?.replaceAll('"', '');
      final spans = <InlineSpan>[];
      if (l10n != null) {
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
          spans.add(
            TextSpan(text: l10n.activityTaskAssigned, style: mutedStyle),
          );
          if (title != null && title.isNotEmpty) {
            spans.add(const TextSpan(text: ' '));
            spans.add(TextSpan(text: title, style: highlightStyle));
          }
        }
      } else {
        spans.add(TextSpan(text: 'assigned ', style: mutedStyle));
        if (title != null && title.isNotEmpty) {
          spans.add(TextSpan(text: title, style: highlightStyle));
        } else {
          spans.add(TextSpan(text: 'a task', style: mutedStyle));
        }
        if (assignee != null && assignee.isNotEmpty) {
          spans.add(TextSpan(text: ' to ', style: mutedStyle));
          spans.add(TextSpan(text: assignee, style: highlightStyle));
        }
      }
      _appendProjectContext(spans, project, l10n, mutedStyle, highlightStyle);
      return spans;

    case 'TaskDeleted':
      final spans = <InlineSpan>[
        TextSpan(
          text: l10n?.activityTaskDeleted ?? 'deleted task',
          style: mutedStyle,
        ),
        if (title != null && title.isNotEmpty) ...[
          const TextSpan(text: ' '),
          TextSpan(text: title, style: highlightStyle),
        ],
      ];
      _appendProjectContext(spans, project, l10n, mutedStyle, highlightStyle);
      return spans;

    case 'ProjectCreated':
      return [
        TextSpan(
          text: l10n?.activityProjectCreated ?? 'created project',
          style: mutedStyle,
        ),
        if (title != null && title.isNotEmpty) ...[
          const TextSpan(text: ' '),
          TextSpan(text: title, style: highlightStyle),
        ],
      ];

    case 'ProjectStatusChanged':
      final toStatus = _formatStatusName(event.newStatus ?? event.status, l10n);
      if (l10n != null) {
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
            TextSpan(
              text: l10n.activityProjectStatusChanged,
              style: mutedStyle,
            ),
            if (toStatus.isNotEmpty) ...[
              const TextSpan(text: ' '),
              TextSpan(text: toStatus, style: highlightStyle),
            ],
          ];
        }
      }
      return [
        if (title != null && title.isNotEmpty) ...[
          TextSpan(text: 'updated project ', style: mutedStyle),
          TextSpan(text: title, style: highlightStyle),
          if (toStatus.isNotEmpty) ...[
            TextSpan(text: ' to ', style: mutedStyle),
            TextSpan(text: toStatus, style: highlightStyle),
          ],
        ] else ...[
          TextSpan(text: 'updated project status', style: mutedStyle),
          if (toStatus.isNotEmpty) ...[
            TextSpan(text: ' to ', style: mutedStyle),
            TextSpan(text: toStatus, style: highlightStyle),
          ],
        ],
      ];

    case 'ProjectArchived':
      return [
        TextSpan(
          text: l10n?.activityProjectArchived ?? 'archived project',
          style: mutedStyle,
        ),
        if (title != null && title.isNotEmpty) ...[
          const TextSpan(text: ' '),
          TextSpan(text: title, style: highlightStyle),
        ],
      ];

    case 'ProjectDeleted':
      return [
        TextSpan(
          text: l10n?.activityProjectDeleted ?? 'deleted project',
          style: mutedStyle,
        ),
        if (title != null && title.isNotEmpty) ...[
          const TextSpan(text: ' '),
          TextSpan(text: title, style: highlightStyle),
        ],
      ];

    case 'MemberAdded':
      final member = event.memberName?.replaceAll('"', '');
      final role = event.role;
      if (l10n != null) {
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
      }
      return [
        if (member != null && member.isNotEmpty) ...[
          TextSpan(text: 'added ', style: mutedStyle),
          TextSpan(text: member, style: highlightStyle),
          if (role != null && role.isNotEmpty) ...[
            TextSpan(text: ' as $role', style: mutedStyle),
          ] else ...[
            TextSpan(text: ' to the workspace', style: mutedStyle),
          ],
        ] else ...[
          TextSpan(text: 'joined the workspace', style: mutedStyle),
        ],
      ];

    case 'MemberRemoved':
      final member = event.memberName?.replaceAll('"', '');
      if (l10n != null) {
        if (member != null && member.isNotEmpty) {
          final full = l10n.activityRemovedMemberFromWorkspace(member);
          return _buildParameterizedSpans(
            full,
            [member],
            mutedStyle,
            highlightStyle,
          );
        } else {
          return [
            TextSpan(text: l10n.activityMemberRemoved, style: mutedStyle),
          ];
        }
      }
      return [
        if (member != null && member.isNotEmpty) ...[
          TextSpan(text: 'removed ', style: mutedStyle),
          TextSpan(text: member, style: highlightStyle),
          TextSpan(text: ' from the workspace', style: mutedStyle),
        ] else ...[
          TextSpan(text: 'left the workspace', style: mutedStyle),
        ],
      ];

    case 'WorkspaceCreated':
      return [
        TextSpan(
          text: l10n?.activityWorkspaceCreated ?? 'created this workspace',
          style: mutedStyle,
        ),
      ];

    case 'WorkspaceUpdated':
      if (l10n != null) {
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
      }
      return [
        if (title != null && title.isNotEmpty) ...[
          TextSpan(text: 'renamed workspace to ', style: mutedStyle),
          TextSpan(text: title, style: highlightStyle),
        ] else ...[
          TextSpan(text: 'updated workspace settings', style: mutedStyle),
        ],
      ];

    default:
      if (l10n != null) {
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
      return [
        TextSpan(text: 'performed ${event.eventType}', style: mutedStyle),
        if (title != null && title.isNotEmpty) ...[
          const TextSpan(text: ' on '),
          TextSpan(text: title, style: highlightStyle),
        ],
      ];
  }
}

void _appendProjectContext(
  List<InlineSpan> spans,
  String? project,
  AppLocalizations? l10n,
  TextStyle mutedStyle,
  TextStyle highlightStyle,
) {
  if (project != null && project.isNotEmpty) {
    spans.add(const TextSpan(text: ' '));
    if (l10n != null) {
      final full = l10n.activityInProject(project);
      spans.addAll(
        _buildParameterizedSpans(full, [project], mutedStyle, highlightStyle),
      );
    } else {
      spans.add(TextSpan(text: 'in ', style: mutedStyle));
      spans.add(TextSpan(text: project, style: highlightStyle));
    }
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
