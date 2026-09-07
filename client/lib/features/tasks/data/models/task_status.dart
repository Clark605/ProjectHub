import 'package:flutter/material.dart';
import 'package:client/core/theme/app_colors.dart';

enum TaskStatus {
  backlog,
  todo,
  inProgress,
  review,
  done;

  static TaskStatus fromString(String? value) {
    if (value == null) return TaskStatus.backlog;
    switch (value
        .toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('_', '')) {
      case 'backlog':
        return TaskStatus.backlog;
      case 'todo':
        return TaskStatus.todo;
      case 'inprogress':
        return TaskStatus.inProgress;
      case 'review':
      case 'inreview':
        return TaskStatus.review;
      case 'done':
        return TaskStatus.done;
      default:
        return TaskStatus.backlog;
    }
  }

  String toServerString() {
    switch (this) {
      case TaskStatus.backlog:
        return 'Backlog';
      case TaskStatus.todo:
        return 'Todo';
      case TaskStatus.inProgress:
        return 'InProgress';
      case TaskStatus.review:
        return 'Review';
      case TaskStatus.done:
        return 'Done';
    }
  }

  String toDisplayString() {
    switch (this) {
      case TaskStatus.backlog:
        return 'Backlog';
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.review:
        return 'Review';
      case TaskStatus.done:
        return 'Done';
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
