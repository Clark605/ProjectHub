import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';
import 'package:client/core/dialog/dialog.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/dashboard/data/models/activity_filter.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

class ActivityFilterBottomSheet extends StatefulWidget {
  final ActivityFilter initialFilter;
  final ValueChanged<ActivityFilter> onApply;
  final List<ProjectDto> availableProjects;

  const ActivityFilterBottomSheet({
    super.key,
    required this.initialFilter,
    required this.onApply,
    this.availableProjects = const [],
  });

  static Future<void> show(
    BuildContext context, {
    required ActivityFilter initialFilter,
    required ValueChanged<ActivityFilter> onApply,
    List<ProjectDto> availableProjects = const [],
  }) {
    return showAppBottomSheet<void>(
      context: context,
      builder: (ctx) => ActivityFilterBottomSheet(
        initialFilter: initialFilter,
        onApply: onApply,
        availableProjects: availableProjects,
      ),
    );
  }

  @override
  State<ActivityFilterBottomSheet> createState() =>
      _ActivityFilterBottomSheetState();
}

class _ActivityFilterBottomSheetState extends State<ActivityFilterBottomSheet> {
  late String _selectedCategory;
  int? _selectedProjectId;
  late ActivitySortOrder _selectedSortOrder;
  late final TextEditingController _searchController;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialFilter.category;
    _selectedProjectId = widget.initialFilter.projectId;
    _selectedSortOrder = widget.initialFilter.sortOrder;
    _searchController = TextEditingController(
      text: widget.initialFilter.search ?? '',
    );
    _selectedDateRange = widget.initialFilter.dateRange;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _selectedCategory = 'All';
      _selectedProjectId = null;
      _selectedSortOrder = ActivitySortOrder.newestFirst;
      _searchController.clear();
      _selectedDateRange = null;
    });
  }

  void _apply() {
    final updated = ActivityFilter(
      category: _selectedCategory,
      projectId: _selectedProjectId,
      search: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      sortOrder: _selectedSortOrder,
      dateRange: _selectedDateRange,
    );
    widget.onApply(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;
    final selectedBgColor = isDark
        ? AppColors.primary.withValues(alpha: 0.22)
        : AppColors.primaryContainer.withValues(alpha: 0.18);
    final selectedTextColor = isDark
        ? AppColors.primary
        : AppColors.onElectricVioletContainer;
    final unselectedTextColor = isDark
        ? AppColors.textSecondary
        : AppColors.lightTextSecondary;
    final selectedBorderColor = isDark
        ? AppColors.primary
        : AppColors.primaryContainer;
    final unselectedBorderColor = isDark
        ? AppColors.border
        : AppColors.lightBorder;

    final categories = [
      {'key': 'All', 'label': l10n.allActivities},
      {'key': 'Tasks', 'label': l10n.taskActivities},
      {'key': 'Projects', 'label': l10n.projectActivities},
      {'key': 'Members', 'label': l10n.memberActivities},
    ];

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppSheetDragHandle(),
            AppSpacing.gapHSm,

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l10n.filterAndSort,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: TextButton(
                        onPressed: _reset,
                        child: Text(l10n.clearFilters),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            AppSpacing.gapHMd,

            // Search Input
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchActivitiesHint,
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: AppIconSize.lg,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          size: AppIconSize.lg,
                        ),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                border: const OutlineInputBorder(borderRadius: AppRadius.r12),
              ),
              onChanged: (_) => setState(() {}),
            ),
            AppSpacing.gapHLg,

            // Category Section
            Text(
              l10n.filterCategory,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            AppSpacing.gapHSm,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: categories.map((cat) {
                final isSelected = _selectedCategory == cat['key'];
                return ChoiceChip(
                  label: Text(cat['label']!),
                  selected: isSelected,
                  selectedColor: selectedBgColor,
                  checkmarkColor: selectedTextColor,
                  side: BorderSide(
                    color: isSelected
                        ? selectedBorderColor
                        : unselectedBorderColor,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? selectedTextColor : unselectedTextColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategory = cat['key']!;
                      });
                    }
                  },
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                );
              }).toList(),
            ),
            AppSpacing.gapHLg,

            // Project Section
            if (widget.availableProjects.isNotEmpty) ...[
              Text(
                l10n.projectActivities,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.gapHSm,
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  ChoiceChip(
                    label: Text(l10n.allActivities),
                    selected: _selectedProjectId == null,
                    selectedColor: selectedBgColor,
                    checkmarkColor: selectedTextColor,
                    side: BorderSide(
                      color: _selectedProjectId == null
                          ? selectedBorderColor
                          : unselectedBorderColor,
                      width: _selectedProjectId == null ? 1.5 : 1.0,
                    ),
                    labelStyle: TextStyle(
                      color: _selectedProjectId == null
                          ? selectedTextColor
                          : unselectedTextColor,
                      fontWeight: _selectedProjectId == null
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedProjectId = null;
                        });
                      }
                    },
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                  ),
                  ...widget.availableProjects.map((proj) {
                    final isSelected = _selectedProjectId == proj.id;
                    return ChoiceChip(
                      label: Text(proj.name),
                      selected: isSelected,
                      selectedColor: selectedBgColor,
                      checkmarkColor: selectedTextColor,
                      side: BorderSide(
                        color: isSelected
                            ? selectedBorderColor
                            : unselectedBorderColor,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? selectedTextColor
                            : unselectedTextColor,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedProjectId = selected ? proj.id : null;
                        });
                      },
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                    );
                  }),
                ],
              ),
              AppSpacing.gapHLg,
            ],

            // Sort Section
            Text(
              l10n.sortBy,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            AppSpacing.gapHSm,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                ChoiceChip(
                  label: Text(l10n.newestFirst),
                  selected: _selectedSortOrder == ActivitySortOrder.newestFirst,
                  selectedColor: selectedBgColor,
                  checkmarkColor: selectedTextColor,
                  side: BorderSide(
                    color: _selectedSortOrder == ActivitySortOrder.newestFirst
                        ? selectedBorderColor
                        : unselectedBorderColor,
                    width: _selectedSortOrder == ActivitySortOrder.newestFirst
                        ? 1.5
                        : 1.0,
                  ),
                  labelStyle: TextStyle(
                    color: _selectedSortOrder == ActivitySortOrder.newestFirst
                        ? selectedTextColor
                        : unselectedTextColor,
                    fontWeight:
                        _selectedSortOrder == ActivitySortOrder.newestFirst
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedSortOrder = ActivitySortOrder.newestFirst;
                      });
                    }
                  },
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                ),
                ChoiceChip(
                  label: Text(l10n.oldestFirst),
                  selected: _selectedSortOrder == ActivitySortOrder.oldestFirst,
                  selectedColor: selectedBgColor,
                  checkmarkColor: selectedTextColor,
                  side: BorderSide(
                    color: _selectedSortOrder == ActivitySortOrder.oldestFirst
                        ? selectedBorderColor
                        : unselectedBorderColor,
                    width: _selectedSortOrder == ActivitySortOrder.oldestFirst
                        ? 1.5
                        : 1.0,
                  ),
                  labelStyle: TextStyle(
                    color: _selectedSortOrder == ActivitySortOrder.oldestFirst
                        ? selectedTextColor
                        : unselectedTextColor,
                    fontWeight:
                        _selectedSortOrder == ActivitySortOrder.oldestFirst
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedSortOrder = ActivitySortOrder.oldestFirst;
                      });
                    }
                  },
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                ),
              ],
            ),
            AppSpacing.gapHXxl,

            // Apply Button
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 50),
              child: ElevatedButton(
                onPressed: _apply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.primary
                      : AppColors.primaryContainer,
                  foregroundColor: isDark
                      ? AppColors.textOnPrimary
                      : AppColors.pureWhite,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.r12,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                child: Text(
                  l10n.applyFilters,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.textOnPrimary
                        : AppColors.pureWhite,
                  ),
                ),
              ),
            ),
            AppSpacing.gapHSm,
          ],
        ),
      ),
    );
  }
}
