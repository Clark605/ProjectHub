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
}
