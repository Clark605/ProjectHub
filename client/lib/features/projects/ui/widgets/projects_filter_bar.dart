import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/widgets/app_text_field.dart';

class ProjectsFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedFilter;
  final List<String> filters;
  final ValueChanged<String> onFilterSelected;

  const ProjectsFilterBar({
    super.key,
    required this.searchController,
    required this.selectedFilter,
    required this.filters,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: AppTextField(
            label: '',
            hintText: 'Search projects by name...',
            prefixIcon: Icons.search_rounded,
            controller: searchController,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filters.map((filter) {
                final isSelected = selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        onFilterSelected(filter);
                      }
                    },
                    backgroundColor: AppColors.surfaceContainer,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.textOnPrimary
                          : AppColors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
