import 'package:client/l10n/generated/app_localizations.dart';

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

  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case ProjectStatus.planning:
        return l10n.statusPlanning;
      case ProjectStatus.active:
        return l10n.statusActive;
      case ProjectStatus.completed:
        return l10n.statusCompleted;
      case ProjectStatus.archived:
        return l10n.statusArchived;
    }
  }
}
