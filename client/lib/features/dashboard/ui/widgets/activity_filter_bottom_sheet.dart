import 'package:flutter/material.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/dashboard/data/models/activity_filter.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class ActivityFilterBottomSheet extends StatefulWidget {
  final ActivityFilter initialFilter;
  final ValueChanged<ActivityFilter> onApply;

  const ActivityFilterBottomSheet({
    super.key,
    required this.initialFilter,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required ActivityFilter initialFilter,
    required ValueChanged<ActivityFilter> onApply,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ActivityFilterBottomSheet(
        initialFilter: initialFilter,
        onApply: onApply,
      ),
    );
  }

  @override
  State<ActivityFilterBottomSheet> createState() =>
      _ActivityFilterBottomSheetState();
}

class _ActivityFilterBottomSheetState extends State<ActivityFilterBottomSheet> {
  late String _selectedCategory;
  late ActivitySortOrder _selectedSortOrder;
  late final TextEditingController _searchController;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialFilter.category;
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
      _selectedSortOrder = ActivitySortOrder.newestFirst;
      _searchController.clear();
      _selectedDateRange = null;
    });
  }

  void _apply() {
    final updated = ActivityFilter(
      category: _selectedCategory,
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
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

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
      {'key': 'All', 'label': l10n?.allActivities ?? 'All'},
      {'key': 'Tasks', 'label': l10n?.taskActivities ?? 'Tasks'},
      {'key': 'Projects', 'label': l10n?.projectActivities ?? 'Projects'},
      {'key': 'Members', 'label': l10n?.memberActivities ?? 'Members'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top drag pill
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n?.filterAndSort ?? 'Filter & Sort',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 48),
                        child: TextButton(
                          onPressed: _reset,
                          child: Text(l10n?.clearFilters ?? 'Reset'),
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
              const SizedBox(height: 12),

              // Search Input
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText:
                      l10n?.searchActivitiesHint ??
                      'Search by actor or item...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Category Section
              Text(
                l10n?.filterCategory ?? 'Category',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
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
                      color: isSelected
                          ? selectedTextColor
                          : unselectedTextColor,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 13,
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
              const SizedBox(height: 16),

              // Sort Section
              Text(
                l10n?.sortBy ?? 'Sort By',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(l10n?.newestFirst ?? 'Newest first'),
                    selected:
                        _selectedSortOrder == ActivitySortOrder.newestFirst,
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
                      fontSize: 13,
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
                    label: Text(l10n?.oldestFirst ?? 'Oldest first'),
                    selected:
                        _selectedSortOrder == ActivitySortOrder.oldestFirst,
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
                      fontSize: 13,
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
              const SizedBox(height: 24),

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
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    l10n?.applyFilters ?? 'Apply Filters',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? AppColors.textOnPrimary : Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
