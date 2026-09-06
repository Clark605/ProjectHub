import 'package:flutter/material.dart';
import 'package:client/core/theme/app_colors.dart';

enum ProjectStatus {
  planning,
  active,
  completed,
  archived;

  static ProjectStatus fromString(String? value) {
    if (value == null) return ProjectStatus.planning;
    switch (value.toLowerCase()) {
      case 'planning':
        return ProjectStatus.planning;
      case 'active':
        return ProjectStatus.active;
      case 'completed':
        return ProjectStatus.completed;
      case 'archived':
        return ProjectStatus.archived;
      default:
        return ProjectStatus.planning;
    }
  }

  String toDisplayString() {
    switch (this) {
      case ProjectStatus.planning:
        return 'Planning';
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.archived:
        return 'Archived';
    }
  }

  Color toColor(BuildContext context) {
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
