import 'package:flutter/material.dart';

enum ShellTab {
  projects(Icons.folder_outlined, Icons.folder_rounded, 'Projects'),
  myTasks(Icons.task_alt_outlined, Icons.task_alt_rounded, 'My Tasks'),
  profile(Icons.person_outline, Icons.person_rounded, 'Profile');

  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const ShellTab(this.icon, this.selectedIcon, this.label);

  static ShellTab fromIndex(int index) {
    if (index >= 0 && index < values.length) {
      return values[index];
    }
    return projects;
  }
}
