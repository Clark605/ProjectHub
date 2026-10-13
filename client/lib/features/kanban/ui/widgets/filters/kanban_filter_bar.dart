import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:client/features/kanban/ui/widgets/filters/kanban_assignee_filter_menu.dart';
import 'package:client/features/kanban/ui/widgets/filters/kanban_priority_filter_menu.dart';
import 'package:client/features/kanban/ui/widgets/filters/kanban_search_input_row.dart';
import 'package:client/features/kanban/ui/widgets/filters/kanban_tag_filter_menu.dart';
import 'package:client/features/tags/data/models/tag_dto.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:flutter/material.dart';

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
    final l10n = context.l10n;

    final hasActiveFilter =
        (widget.selectedPriority != null &&
            widget.selectedPriority!.isNotEmpty &&
            widget.selectedPriority!.toLowerCase() != 'all') ||
        (widget.selectedAssignee != null &&
            widget.selectedAssignee!.isNotEmpty) ||
        (widget.selectedTagId != null) ||
        (widget.searchQuery != null && widget.searchQuery!.isNotEmpty);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
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
            AppSpacing.gapHSm,
          ],
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (!_isSearchExpanded)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: ActionChip(
                      avatar: const Icon(
                        Icons.search_rounded,
                        size: AppIconSize.sm,
                      ),
                      label: Text(l10n.search),
                      onPressed: () => setState(() => _isSearchExpanded = true),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: KanbanPriorityFilterMenu(
                    selectedPriority: widget.selectedPriority,
                    onPrioritySelected: widget.onPrioritySelected,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: KanbanAssigneeFilterMenu(
                    selectedAssignee: widget.selectedAssignee,
                    members: widget.members,
                    onAssigneeSelected: widget.onAssigneeSelected,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: KanbanTagFilterMenu(
                    selectedTagId: widget.selectedTagId,
                    availableTags: widget.availableTags,
                    onTagSelected: widget.onTagSelected,
                  ),
                ),
                if (hasActiveFilter)
                  ActionChip(
                    avatar: const Icon(
                      Icons.filter_alt_off_rounded,
                      size: AppIconSize.sm,
                    ),
                    label: Text(l10n.clearFilters),
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
