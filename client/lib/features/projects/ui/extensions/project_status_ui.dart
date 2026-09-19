import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/projects/data/models/project_status.dart';

extension ProjectStatusUI on ProjectStatus {
  Color toColor([BuildContext? context]) {
    switch (this) {
      case ProjectStatus.planning:
        return AppColors.info;
      case ProjectStatus.active:
        return AppColors.primary;
      case ProjectStatus.completed:
        return AppColors.success;
      case ProjectStatus.archived:
        return AppColors.textSecondary;
    }
  }
}
