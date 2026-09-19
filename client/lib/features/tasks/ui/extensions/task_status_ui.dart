import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/tasks/data/models/task_status.dart';
import 'package:client/l10n/generated/app_localizations.dart';

extension TaskStatusUI on TaskStatus {
  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case TaskStatus.backlog:
        return l10n.statusBacklog;
      case TaskStatus.todo:
        return l10n.statusTodo;
      case TaskStatus.inProgress:
        return l10n.statusInProgress;
      case TaskStatus.review:
        return l10n.statusReview;
      case TaskStatus.done:
        return l10n.statusDone;
    }
  }

  Color toColor() {
    switch (this) {
      case TaskStatus.backlog:
        return AppColors.textSecondary;
      case TaskStatus.todo:
        return AppColors.info;
      case TaskStatus.inProgress:
        return AppColors.primary;
      case TaskStatus.review:
        return AppColors.warning;
      case TaskStatus.done:
        return AppColors.success;
    }
  }

  IconData toIcon() {
    switch (this) {
      case TaskStatus.backlog:
        return Icons.inbox_rounded;
      case TaskStatus.todo:
        return Icons.format_list_bulleted_rounded;
      case TaskStatus.inProgress:
        return Icons.pending_actions_rounded;
      case TaskStatus.review:
        return Icons.rate_review_outlined;
      case TaskStatus.done:
        return Icons.check_circle_outline_rounded;
    }
  }
}
