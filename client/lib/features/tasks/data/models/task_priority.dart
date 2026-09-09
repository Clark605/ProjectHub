import 'package:flutter/material.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/l10n/generated/app_localizations.dart';

enum TaskPriority {
  low,
  medium,
  high,
  urgent;

  static TaskPriority fromString(String? value) {
    if (value == null) return TaskPriority.medium;
    switch (value.toLowerCase().trim()) {
      case 'low':
        return TaskPriority.low;
      case 'medium':
        return TaskPriority.medium;
      case 'high':
        return TaskPriority.high;
      case 'urgent':
        return TaskPriority.urgent;
      default:
        return TaskPriority.medium;
    }
  }

  String toServerString() {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

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

  String toDisplayString() {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
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
