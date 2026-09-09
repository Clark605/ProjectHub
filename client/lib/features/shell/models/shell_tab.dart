import 'package:flutter/material.dart';
import 'package:client/l10n/generated/app_localizations.dart';

enum ShellTab {
  dashboard(Icons.dashboard_outlined, Icons.dashboard_rounded, 'Dashboard'),
  projects(Icons.folder_outlined, Icons.folder_rounded, 'Projects'),
  myTasks(Icons.task_alt_outlined, Icons.task_alt_rounded, 'My Tasks'),
  profile(Icons.person_outline, Icons.person_rounded, 'Profile');

  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const ShellTab(this.icon, this.selectedIcon, this.label);

  String localizedName(AppLocalizations l10n) {
    switch (this) {
      case ShellTab.dashboard:
        return l10n.tabDashboard;
      case ShellTab.projects:
        return l10n.tabProjects;
      case ShellTab.myTasks:
        return l10n.tabMyTasks;
      case ShellTab.profile:
        return l10n.tabProfile;
    }
  }

  static ShellTab fromIndex(int index) {
    if (index >= 0 && index < values.length) {
      return values[index];
    }
    return dashboard;
  }
}
