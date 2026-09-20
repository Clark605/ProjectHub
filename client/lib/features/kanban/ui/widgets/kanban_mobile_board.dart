import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/workspace_accent.dart';
import 'package:client/features/kanban/ui/widgets/kanban_column.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/task_status.dart';
import 'package:client/features/tasks/ui/extensions/task_status_ui.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class KanbanMobileBoard extends StatefulWidget {
  final PageController pageController;
  final int currentColumnIndex;
  final ValueChanged<int> onColumnChanged;
  final Map<TaskStatus, List<TaskDto>> tasksByStatus;
  final bool isArchived;
  final String? wsAccent;
  final ValueChanged<TaskStatus> onAddTask;
  final ValueChanged<TaskDto> onTaskTap;
  final ValueChanged<TaskDto> onTaskMove;
  final ValueChanged<TaskDto> onTaskDelete;

  const KanbanMobileBoard({
    super.key,
    required this.pageController,
    required this.currentColumnIndex,
    required this.onColumnChanged,
    required this.tasksByStatus,
    required this.isArchived,
    this.wsAccent,
    required this.onAddTask,
    required this.onTaskTap,
    required this.onTaskMove,
    required this.onTaskDelete,
  });

  @override
  State<KanbanMobileBoard> createState() => _KanbanMobileBoardState();
}

class _KanbanMobileBoardState extends State<KanbanMobileBoard> {
  final ScrollController _chipScrollController = ScrollController();
  late final List<GlobalKey> _chipKeys;

  @override
  void initState() {
    super.initState();
    _chipKeys = List.generate(TaskStatus.values.length, (_) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollToChip(widget.currentColumnIndex);
      }
    });
  }

  @override
  void didUpdateWidget(KanbanMobileBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentColumnIndex != oldWidget.currentColumnIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToChip(widget.currentColumnIndex);
        }
      });
    }
  }

  @override
  void dispose() {
    _chipScrollController.dispose();
    super.dispose();
  }

  void _scrollToChip(int index) {
    if (index < 0 || index >= _chipKeys.length) return;
    final context = _chipKeys[index].currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.5,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final accentColor =
        widget.wsAccent != null && widget.wsAccent!.trim().isNotEmpty
        ? WorkspaceAccent.fromId(
            widget.wsAccent!,
          ).resolvedColor(theme.brightness)
        : null;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            controller: _chipScrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: TaskStatus.values.asMap().entries.map((entry) {
                final idx = entry.key;
                final status = entry.value;
                final isSelected = idx == widget.currentColumnIndex;
                final count = widget.tasksByStatus[status]?.length ?? 0;
                final statusName = l10n != null
                    ? status.localizedName(l10n)
                    : status.toDisplayString();

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    key: _chipKeys[idx],
                    selected: isSelected,
                    showCheckmark: false,
                    selectedColor: accentColor?.withValues(alpha: 0.18),
                    side: BorderSide(
                      color: isSelected
                          ? (accentColor ?? theme.colorScheme.primary)
                          : theme.colorScheme.outlineVariant,
                    ),
                    avatar: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: status.toColor(),
                        shape: BoxShape.circle,
                      ),
                    ),
                    label: Text('$statusName ($count)'),
                    labelStyle: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? (accentColor ??
                                (isDark ? Colors.white : Colors.black))
                          : (isDark
                                ? AppColors.textSecondary
                                : AppColors.lightTextSecondary),
                      fontSize: 12,
                    ),
                    onSelected: (_) {
                      widget.onColumnChanged(idx);
                      _scrollToChip(idx);
                      widget.pageController.animateToPage(
                        idx,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: widget.pageController,
            itemCount: TaskStatus.values.length,
            onPageChanged: (index) {
              widget.onColumnChanged(index);
              _scrollToChip(index);
            },
            itemBuilder: (context, index) {
              final status = TaskStatus.values[index];
              final columnTasks = widget.tasksByStatus[status] ?? [];
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: KanbanColumn(
                  status: status,
                  tasks: columnTasks,
                  isArchived: widget.isArchived,
                  activeWorkspaceAccent: widget.wsAccent,
                  onAddTask: () => widget.onAddTask(status),
                  onTaskTap: widget.onTaskTap,
                  onTaskMove: widget.onTaskMove,
                  onTaskDelete: widget.onTaskDelete,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
