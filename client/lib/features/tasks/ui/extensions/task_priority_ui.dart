import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/tasks/data/models/task_priority.dart';
import 'package:client/l10n/generated/app_localizations.dart';

extension TaskPriorityUI on TaskPriority {
  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case TaskPriority.low:
        return l10n.priorityLow;
      case TaskPriority.medium:
        return l10n.priorityMedium;
      case TaskPriority.high:
        return l10n.priorityHigh;
      case TaskPriority.urgent:
        return l10n.priorityUrgent;
    }
  }

  Color toColor() {
    switch (this) {
      case TaskPriority.low:
        return AppColors.textSecondary;
      case TaskPriority.medium:
        return AppColors.skyBlue;
      case TaskPriority.high:
        return AppColors.warning;
      case TaskPriority.urgent:
        return AppColors.error;
    }
  }

  IconData toIcon() {
    switch (this) {
      case TaskPriority.low:
        return Icons.arrow_downward_rounded;
      case TaskPriority.medium:
        return Icons.remove_rounded;
      case TaskPriority.high:
        return Icons.arrow_upward_rounded;
      case TaskPriority.urgent:
        return Icons.priority_high_rounded;
    }
  }
}
