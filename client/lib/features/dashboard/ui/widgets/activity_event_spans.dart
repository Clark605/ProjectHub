import 'package:flutter/material.dart';

import 'package:client/features/dashboard/data/models/activity_event_dto.dart';
import 'package:client/l10n/generated/app_localizations.dart';

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
  final title = event.targetTitle;

  switch (event.eventType) {
    case 'TaskCreated':
      return [
        TextSpan(
          text: l10n?.activityTaskCreated ?? 'created task',
          style: mutedStyle,
        ),
        if (title != null && title.isNotEmpty) ...[
          const TextSpan(text: ' '),
          TextSpan(text: '"$title"', style: highlightStyle),
        ],
      ];

    case 'TaskStatusChanged':
      final toStatus = event.newStatus ?? event.status;
      if (l10n != null) {
        if (title != null && title.isNotEmpty && toStatus != null && toStatus.isNotEmpty) {
          final full = l10n.activityMovedTo(title, toStatus);
          return _buildParameterizedSpans(full, [title, toStatus], mutedStyle, highlightStyle);
        } else if (toStatus != null && toStatus.isNotEmpty) {
          final full = l10n.activityTaskMovedToStatus(toStatus);
          return _buildParameterizedSpans(full, [toStatus], mutedStyle, highlightStyle);
        } else {
          return [
            TextSpan(text: l10n.activityTaskStatusChanged, style: mutedStyle),
          ];
        }
      }
      return [
        if (title != null && title.isNotEmpty) ...[
          TextSpan(text: 'moved ', style: mutedStyle),
          TextSpan(text: '"$title"', style: highlightStyle),
          if (toStatus != null && toStatus.isNotEmpty) ...[
            TextSpan(text: ' to ', style: mutedStyle),
            TextSpan(text: toStatus, style: highlightStyle),
          ],
        ] else ...[
          TextSpan(
            text: 'updated task status',
            style: mutedStyle,
          ),
          if (toStatus != null && toStatus.isNotEmpty) ...[
            TextSpan(text: ' to ', style: mutedStyle),
            TextSpan(text: toStatus, style: highlightStyle),
          ],
        ],
      ];

    case 'TaskAssigned':
      final assignee = event.assigneeName;
      if (l10n != null) {
        if (assignee != null && assignee.isNotEmpty) {
          if (title != null && title.isNotEmpty) {
            final full = l10n.activityAssignedTo(title, assignee);
            return _buildParameterizedSpans(full, [title, assignee], mutedStyle, highlightStyle);
          } else {
            final full = l10n.activityAssignedTaskTo(assignee);
            return _buildParameterizedSpans(full, [assignee], mutedStyle, highlightStyle);
          }
        } else {
          return [
            TextSpan(text: l10n.activityTaskAssigned, style: mutedStyle),
            if (title != null && title.isNotEmpty) ...[
              const TextSpan(text: ' '),
              TextSpan(text: '"$title"', style: highlightStyle),
            ],
          ];
        }
      }
      return [
        TextSpan(text: 'assigned ', style: mutedStyle),
        if (title != null && title.isNotEmpty) ...[
          TextSpan(text: '"$title"', style: highlightStyle),
        ] else ...[
          TextSpan(text: 'a task', style: mutedStyle),
        ],
        if (assignee != null && assignee.isNotEmpty) ...[
          TextSpan(text: ' to ', style: mutedStyle),
          TextSpan(text: assignee, style: highlightStyle),
        ],
      ];

    case 'TaskDeleted':
      return [
        TextSpan(
          text: l10n?.activityTaskDeleted ?? 'deleted task',
          style: mutedStyle,
        ),
        if (title != null && title.isNotEmpty) ...[
          const TextSpan(text: ' '),
          TextSpan(text: '"$title"', style: highlightStyle),
        ],
      ];

    case 'ProjectCreated':
      return [
        TextSpan(
          text: l10n?.activityProjectCreated ?? 'created project',
          style: mutedStyle,
        ),
        if (title != null && title.isNotEmpty) ...[
          const TextSpan(text: ' '),
          TextSpan(text: '"$title"', style: highlightStyle),
        ],
      ];

    case 'ProjectStatusChanged':
      final toStatus = event.newStatus ?? event.status;
      if (l10n != null) {
        if (title != null && title.isNotEmpty && toStatus != null && toStatus.isNotEmpty) {
          final full = l10n.activityUpdatedProjectTo(title, toStatus);
          return _buildParameterizedSpans(full, [title, toStatus], mutedStyle, highlightStyle);
        } else {
          return [
            TextSpan(text: l10n.activityProjectStatusChanged, style: mutedStyle),
            if (toStatus != null && toStatus.isNotEmpty) ...[
              const TextSpan(text: ' '),
              TextSpan(text: toStatus, style: highlightStyle),
            ],
          ];
        }
      }
      return [
        if (title != null && title.isNotEmpty) ...[
          TextSpan(text: 'updated project ', style: mutedStyle),
          TextSpan(text: '"$title"', style: highlightStyle),
          if (toStatus != null && toStatus.isNotEmpty) ...[
            TextSpan(text: ' to ', style: mutedStyle),
            TextSpan(text: toStatus, style: highlightStyle),
          ],
        ] else ...[
          TextSpan(
            text: 'updated project status',
            style: mutedStyle,
          ),
          if (toStatus != null && toStatus.isNotEmpty) ...[
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
          TextSpan(text: '"$title"', style: highlightStyle),
        ],
      ];

    case 'MemberAdded':
      final member = event.memberName;
      final role = event.role;
      if (l10n != null) {
        if (member != null && member.isNotEmpty) {
          if (role != null && role.isNotEmpty) {
            final full = l10n.activityAddedMemberAsRole(member, role);
            return _buildParameterizedSpans(full, [member, role], mutedStyle, highlightStyle);
          } else {
            final full = l10n.activityAddedMemberToWorkspace(member);
            return _buildParameterizedSpans(full, [member], mutedStyle, highlightStyle);
          }
        } else {
          return [
            TextSpan(text: l10n.activityMemberAdded, style: mutedStyle),
          ];
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
          TextSpan(
            text: 'joined the workspace',
            style: mutedStyle,
          ),
        ],
      ];

    case 'MemberRemoved':
      final member = event.memberName;
      if (l10n != null) {
        if (member != null && member.isNotEmpty) {
          final full = l10n.activityRemovedMemberFromWorkspace(member);
          return _buildParameterizedSpans(full, [member], mutedStyle, highlightStyle);
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
          TextSpan(
            text: 'left the workspace',
            style: mutedStyle,
          ),
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
          return _buildParameterizedSpans(full, [title], mutedStyle, highlightStyle);
        } else {
          return [
            TextSpan(text: l10n.activityWorkspaceUpdated, style: mutedStyle),
          ];
        }
      }
      return [
        if (title != null && title.isNotEmpty) ...[
          TextSpan(text: 'renamed workspace to ', style: mutedStyle),
          TextSpan(text: '"$title"', style: highlightStyle),
        ] else ...[
          TextSpan(
            text: 'updated workspace settings',
            style: mutedStyle,
          ),
        ],
      ];

    default:
      if (l10n != null) {
        if (title != null && title.isNotEmpty) {
          final full = l10n.activityPerformedEventOn(event.eventType, title);
          return _buildParameterizedSpans(full, [event.eventType, title], mutedStyle, highlightStyle);
        } else {
          final full = l10n.activityPerformedEvent(event.eventType);
          return _buildParameterizedSpans(full, [event.eventType], mutedStyle, highlightStyle);
        }
      }
      return [
        TextSpan(text: 'performed ${event.eventType}', style: mutedStyle),
        if (title != null && title.isNotEmpty) ...[
          const TextSpan(text: ' on '),
          TextSpan(text: '"$title"', style: highlightStyle),
        ],
      ];
  }
}

List<InlineSpan> _buildParameterizedSpans(
  String fullText,
  List<String> highlights,
  TextStyle mutedStyle,
  TextStyle highlightStyle,
) {
  if (highlights.isEmpty) {
    return [TextSpan(text: fullText, style: mutedStyle)];
  }

  final spans = <InlineSpan>[];
  var currentIndex = 0;

  while (currentIndex < fullText.length) {
    int? earliestStart;
    String? earliestMatch;

    for (final h in highlights) {
      if (h.isEmpty) continue;
      final quoted = '"$h"';
      final idxQuoted = fullText.indexOf(quoted, currentIndex);
      if (idxQuoted != -1 && (earliestStart == null || idxQuoted < earliestStart)) {
        earliestStart = idxQuoted;
        earliestMatch = quoted;
      }
      final idxPlain = fullText.indexOf(h, currentIndex);
      if (idxPlain != -1 && (earliestStart == null || idxPlain < earliestStart)) {
        earliestStart = idxPlain;
        earliestMatch = h;
      }
    }

    if (earliestStart != null && earliestMatch != null) {
      if (earliestStart > currentIndex) {
        spans.add(TextSpan(
          text: fullText.substring(currentIndex, earliestStart),
          style: mutedStyle,
        ));
      }
      spans.add(TextSpan(text: earliestMatch, style: highlightStyle));
      currentIndex = earliestStart + earliestMatch.length;
    } else {
      spans.add(TextSpan(
        text: fullText.substring(currentIndex),
        style: mutedStyle,
      ));
      break;
    }
  }

  return spans;
}
