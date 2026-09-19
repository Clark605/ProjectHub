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
        TextSpan(text: l10n?.activityTaskCreated ?? 'created task', style: mutedStyle),
        if (title != null && title.isNotEmpty) ...[
          const TextSpan(text: ' '),
          TextSpan(text: '"$title"', style: highlightStyle),
        ],
      ];

    case 'TaskStatusChanged':
      final toStatus = event.newStatus ?? event.status;
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
            text: l10n?.activityTaskStatusChanged ?? 'updated task status',
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
        TextSpan(text: l10n?.activityTaskDeleted ?? 'deleted task', style: mutedStyle),
        if (title != null && title.isNotEmpty) ...[
          const TextSpan(text: ' '),
          TextSpan(text: '"$title"', style: highlightStyle),
        ],
      ];

    case 'ProjectCreated':
      return [
        TextSpan(text: l10n?.activityProjectCreated ?? 'created project', style: mutedStyle),
        if (title != null && title.isNotEmpty) ...[
          const TextSpan(text: ' '),
          TextSpan(text: '"$title"', style: highlightStyle),
        ],
      ];

    case 'ProjectStatusChanged':
      final toStatus = event.newStatus ?? event.status;
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
            text: l10n?.activityProjectStatusChanged ?? 'updated project status',
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
        TextSpan(text: l10n?.activityProjectArchived ?? 'archived project', style: mutedStyle),
        if (title != null && title.isNotEmpty) ...[
          const TextSpan(text: ' '),
          TextSpan(text: '"$title"', style: highlightStyle),
        ],
      ];

    case 'MemberAdded':
      final member = event.memberName;
      final role = event.role;
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
            text: l10n?.activityMemberAdded ?? 'joined the workspace',
            style: mutedStyle,
          ),
        ],
      ];

    case 'MemberRemoved':
      final member = event.memberName;
      return [
        if (member != null && member.isNotEmpty) ...[
          TextSpan(text: 'removed ', style: mutedStyle),
          TextSpan(text: member, style: highlightStyle),
          TextSpan(text: ' from the workspace', style: mutedStyle),
        ] else ...[
          TextSpan(
            text: l10n?.activityMemberRemoved ?? 'left the workspace',
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
      return [
        if (title != null && title.isNotEmpty) ...[
          TextSpan(text: 'renamed workspace to ', style: mutedStyle),
          TextSpan(text: '"$title"', style: highlightStyle),
        ] else ...[
          TextSpan(
            text: l10n?.activityWorkspaceUpdated ?? 'updated workspace settings',
            style: mutedStyle,
          ),
        ],
      ];

    default:
      return [
        TextSpan(text: 'performed ${event.eventType}', style: mutedStyle),
        if (title != null && title.isNotEmpty) ...[
          const TextSpan(text: ' on '),
          TextSpan(text: '"$title"', style: highlightStyle),
        ],
      ];
  }
}
