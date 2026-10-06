import 'package:client/features/tags/data/models/tag_dto.dart';
import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/workspace_accent.dart';
import 'package:client/features/kanban/ui/widgets/column/kanban_column.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/task_status.dart';
import 'package:client/features/tasks/ui/extensions/task_status_ui.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class KanbanMobileBoard extends StatefulWidget {
  final PageController? pageController;
  final int? currentColumnIndex;
  final ValueChanged<int>? onColumnChanged;
  final Map<TaskStatus, List<TaskDto>> tasksByStatus;
  final bool isArchived;
  final String? wsAccent;
  final ValueChanged<TaskStatus>? onAddTask;
  final ValueChanged<TaskDto>? onTaskTap;
  final ValueChanged<TaskDto>? onTaskMove;
  final ValueChanged<TaskDto>? onTaskDelete;
  final ValueChanged<TagDto>? onTagTap;

  const KanbanMobileBoard({
    super.key,
    this.pageController,
    this.currentColumnIndex,
    this.onColumnChanged,
    required this.tasksByStatus,
    required this.isArchived,
    this.wsAccent,
    this.onAddTask,
    this.onTaskTap,
    this.onTaskMove,
    this.onTaskDelete,
    this.onTagTap,
  });

  @override
  State<KanbanMobileBoard> createState() => _KanbanMobileBoardState();
}

class _KanbanMobileBoardState extends State<KanbanMobileBoard> {
  final ScrollController _chipScrollController = ScrollController();
  late final List<GlobalKey> _chipKeys;
  late int _currentColumnIndex;
  late final PageController _pageController;
  late final bool _ownsController;
  bool _isAnimatingPage = false;

  @override
  void initState() {
    super.initState();
    _currentColumnIndex = widget.currentColumnIndex ?? 0;
    _ownsController = widget.pageController == null;
    _pageController =
        widget.pageController ??
        PageController(initialPage: _currentColumnIndex);
    _chipKeys = List.generate(TaskStatus.values.length, (_) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scrollToChip(_currentColumnIndex);
      }
    });
  }

  @override
  void dispose() {
    _chipScrollController.dispose();
    if (_ownsController) {
      _pageController.dispose();
    }
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
    final accentColor = WorkspaceAccent.resolve(
      widget.wsAccent,
      theme.brightness,
    );

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
                final isSelected = idx == _currentColumnIndex;
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
                          : AppColors.textSecondaryColor(isDark),
                      fontSize: 12,
                    ),
                    onSelected: (_) async {
                      if (_currentColumnIndex == idx) return;
                      setState(() => _currentColumnIndex = idx);
                      _scrollToChip(idx);
                      widget.onColumnChanged?.call(idx);
                      _isAnimatingPage = true;
                      await _pageController.animateToPage(
                        idx,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      _isAnimatingPage = false;
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: TaskStatus.values.length,
            onPageChanged: (index) {
              if (_isAnimatingPage) return;
              if (_currentColumnIndex != index) {
                setState(() => _currentColumnIndex = index);
                _scrollToChip(index);
                widget.onColumnChanged?.call(index);
              }
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
                  accent: accentColor,
                  onAddTask: widget.onAddTask != null
                      ? () => widget.onAddTask!(status)
                      : null,
                  onTaskTap: widget.onTaskTap,
                  onTaskMove: widget.onTaskMove,
                  onTaskDelete: widget.onTaskDelete,
                  onTagTap: widget.onTagTap,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
