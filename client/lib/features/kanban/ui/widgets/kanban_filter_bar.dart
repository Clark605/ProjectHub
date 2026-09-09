import 'package:flutter/material.dart';

import 'package:client/features/tasks/data/models/task_priority.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class KanbanFilterBar extends StatefulWidget {
  final String? selectedPriority;
  final String? selectedAssignee;
  final String? searchQuery;
  final List<MemberDto> members;
  final ValueChanged<String?> onPrioritySelected;
  final ValueChanged<String?> onAssigneeSelected;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearFilters;

  const KanbanFilterBar({
    super.key,
    this.selectedPriority,
    this.selectedAssignee,
    this.searchQuery,
    this.members = const [],
    required this.onPrioritySelected,
    required this.onAssigneeSelected,
    required this.onSearchChanged,
    required this.onClearFilters,
  });

  @override
  State<KanbanFilterBar> createState() => _KanbanFilterBarState();
}

class _KanbanFilterBarState extends State<KanbanFilterBar> {
  bool _isSearchExpanded = false;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    _isSearchExpanded =
        widget.searchQuery != null && widget.searchQuery!.isNotEmpty;
  }

  @override
  void didUpdateWidget(covariant KanbanFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != _searchController.text) {
      _searchController.text = widget.searchQuery ?? '';
      if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
        _isSearchExpanded = true;
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final hasActiveFilter =
        (widget.selectedPriority != null &&
            widget.selectedPriority!.isNotEmpty &&
            widget.selectedPriority!.toLowerCase() != 'all') ||
        (widget.selectedAssignee != null &&
            widget.selectedAssignee!.isNotEmpty) ||
        (widget.searchQuery != null && widget.searchQuery!.isNotEmpty);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search row when expanded
          if (_isSearchExpanded) ...[
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: widget.onSearchChanged,
                      autofocus: true,
                      style: theme.textTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText: l10n?.taskTitlePlaceholder ??
                            'Search tasks by title or description...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        prefixIcon: const Icon(Icons.search_rounded, size: 18),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 16),
                                onPressed: () {
                                  _searchController.clear();
                                  widget.onSearchChanged('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: l10n?.closeSearch ?? 'Close search',
                  onPressed: () {
                    setState(() {
                      _isSearchExpanded = false;
                      _searchController.clear();
                      widget.onSearchChanged('');
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          // Filter chips row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Search toggle button
                if (!_isSearchExpanded)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      avatar: const Icon(Icons.search_rounded, size: 16),
                      label: Text(l10n?.search ?? 'Search'),
                      onPressed: () => setState(() => _isSearchExpanded = true),
                    ),
                  ),

                // Priority dropdown / chips
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: PopupMenuButton<String>(
                    tooltip: l10n?.filterByPriority ?? 'Filter by priority',
                    onSelected: (val) {
                      widget.onPrioritySelected(val == 'all' ? null : val);
                    },
                    child: Chip(
                      avatar: Icon(
                        Icons.flag_outlined,
                        size: 16,
                        color: widget.selectedPriority != null
                            ? TaskPriority.fromString(
                                widget.selectedPriority,
                              ).toColor()
                            : null,
                      ),
                      label: Text(
                        widget.selectedPriority != null
                            ? '${l10n?.taskPriority ?? 'Priority'}: ${widget.selectedPriority}'
                            : (l10n?.taskPriority ?? 'Priority'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: widget.selectedPriority != null
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      deleteIcon: widget.selectedPriority != null
                          ? const Icon(Icons.close_rounded, size: 14)
                          : null,
                      onDeleted: widget.selectedPriority != null
                          ? () => widget.onPrioritySelected(null)
                          : null,
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'all',
                        child: Text(l10n?.allPriorities ?? 'All Priorities'),
                      ),
                      ...TaskPriority.values.map(
                        (p) => PopupMenuItem(
                          value: p.toServerString(),
                          child: Row(
                            children: [
                              Icon(p.toIcon(), size: 16, color: p.toColor()),
                              const SizedBox(width: 8),
                              Text(
                                l10n != null
                                    ? p.localizedName(l10n)
                                    : p.toDisplayString(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Assignee filter dropdown
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: PopupMenuButton<String>(
                    tooltip: l10n?.filterByAssignee ?? 'Filter by assignee',
                    onSelected: (val) {
                      widget.onAssigneeSelected(val == 'all' ? null : val);
                    },
                    child: Chip(
                      avatar: const Icon(
                        Icons.person_outline_rounded,
                        size: 16,
                      ),
                      label: Text(
                        _resolveAssigneeLabel(widget.selectedAssignee, l10n),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: widget.selectedAssignee != null
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      deleteIcon: widget.selectedAssignee != null
                          ? const Icon(Icons.close_rounded, size: 14)
                          : null,
                      onDeleted: widget.selectedAssignee != null
                          ? () => widget.onAssigneeSelected(null)
                          : null,
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'all',
                        child: Text(l10n?.allAssignees ?? 'All Assignees'),
                      ),
                      PopupMenuItem(
                        value: 'unassigned',
                        child: Text(l10n?.unassigned ?? 'Unassigned'),
                      ),
                      ...widget.members.map(
                        (m) =>
                            PopupMenuItem(value: m.userId, child: Text(m.name)),
                      ),
                    ],
                  ),
                ),

                // Clear all filters chip
                if (hasActiveFilter)
                  ActionChip(
                    avatar: const Icon(Icons.filter_alt_off_rounded, size: 16),
                    label: Text(l10n?.clearFilters ?? 'Clear Filters'),
                    onPressed: () {
                      _searchController.clear();
                      widget.onClearFilters();
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _resolveAssigneeLabel(String? assigneeId, AppLocalizations? l10n) {
    if (assigneeId == null || assigneeId.isEmpty || assigneeId == 'all') {
      return l10n?.assignee ?? 'Assignee';
    }
    if (assigneeId == 'unassigned') return l10n?.unassigned ?? 'Unassigned';
    final member = widget.members
        .where((m) => m.userId == assigneeId)
        .firstOrNull;
    return member != null ? member.name : (l10n?.assignee ?? 'Assignee');
  }
}
