import 'package:flutter/material.dart';

import 'package:client/features/kanban/ui/widgets/kanban_assignee_filter_menu.dart';
import 'package:client/features/kanban/ui/widgets/kanban_priority_filter_menu.dart';
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                        hintText:
                            l10n?.taskTitlePlaceholder ??
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (!_isSearchExpanded)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      avatar: const Icon(Icons.search_rounded, size: 16),
                      label: Text(l10n?.search ?? 'Search'),
                      onPressed: () => setState(() => _isSearchExpanded = true),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: KanbanPriorityFilterMenu(
                    selectedPriority: widget.selectedPriority,
                    onPrioritySelected: widget.onPrioritySelected,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: KanbanAssigneeFilterMenu(
                    selectedAssignee: widget.selectedAssignee,
                    members: widget.members,
                    onAssigneeSelected: widget.onAssigneeSelected,
                  ),
                ),
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
}
