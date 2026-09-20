import 'package:flutter/material.dart';

import 'package:client/features/kanban/ui/widgets/kanban_assignee_filter_menu.dart';
import 'package:client/features/kanban/ui/widgets/kanban_priority_filter_menu.dart';
import 'package:client/features/kanban/ui/widgets/kanban_search_input_row.dart';
import 'package:client/features/kanban/ui/widgets/kanban_tag_filter_menu.dart';
import 'package:client/features/tags/data/models/tag_dto.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class KanbanFilterBar extends StatefulWidget {
  final String? selectedPriority;
  final String? selectedAssignee;
  final int? selectedTagId;
  final List<TagDto> availableTags;
  final String? searchQuery;
  final List<MemberDto> members;
  final ValueChanged<String?> onPrioritySelected;
  final ValueChanged<String?> onAssigneeSelected;
  final ValueChanged<int?> onTagSelected;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearFilters;

  const KanbanFilterBar({
    super.key,
    this.selectedPriority,
    this.selectedAssignee,
    this.selectedTagId,
    this.availableTags = const [],
    this.searchQuery,
    this.members = const [],
    required this.onPrioritySelected,
    required this.onAssigneeSelected,
    required this.onTagSelected,
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
    final l10n = AppLocalizations.of(context);

    final hasActiveFilter =
        (widget.selectedPriority != null &&
            widget.selectedPriority!.isNotEmpty &&
            widget.selectedPriority!.toLowerCase() != 'all') ||
        (widget.selectedAssignee != null &&
            widget.selectedAssignee!.isNotEmpty) ||
        (widget.selectedTagId != null) ||
        (widget.searchQuery != null && widget.searchQuery!.isNotEmpty);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isSearchExpanded) ...[
            KanbanSearchInputRow(
              controller: _searchController,
              onChanged: widget.onSearchChanged,
              onClose: () {
                setState(() {
                  _isSearchExpanded = false;
                  _searchController.clear();
                  widget.onSearchChanged('');
                });
              },
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
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: KanbanTagFilterMenu(
                    selectedTagId: widget.selectedTagId,
                    availableTags: widget.availableTags,
                    onTagSelected: widget.onTagSelected,
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
