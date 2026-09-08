import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/projects/cubit/projects_list_cubit.dart';
import 'package:client/features/projects/cubit/projects_list_state.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class ProjectsFilterBar extends StatelessWidget {
  const ProjectsFilterBar({super.key});

  static const List<String> _filters = [
    'All',
    'Planning',
    'Active',
    'Completed',
    'Archived',
  ];

  String _getFilterLabel(BuildContext context, String filter) {
    final l10n = AppLocalizations.of(context);
    switch (filter.toLowerCase()) {
      case 'all':
        return l10n?.statusAll ?? 'All';
      case 'planning':
        return l10n?.statusPlanning ?? 'Planning';
      case 'active':
        return l10n?.statusActive ?? 'Active';
      case 'completed':
        return l10n?.statusCompleted ?? 'Completed';
      case 'archived':
        return l10n?.statusArchived ?? 'Archived';
      default:
        return filter;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProjectsListCubit, ProjectsListState>(
      builder: (context, state) {
        final currentFilter = state.maybeWhen(
          loaded: (p, a, selected) => selected,
          empty: (selected) => selected,
          orElse: () => 'All',
        );

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: _filters.map((filter) {
              final isSelected =
                  currentFilter.toLowerCase() == filter.toLowerCase();

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_getFilterLabel(context, filter)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      context.read<ProjectsListCubit>().filterByStatus(filter);
                    }
                  },
                  selectedColor: AppColors.electricVioletContainer,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13,
                  ),
                  backgroundColor: AppColors.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.electricVioletContainer
                          : AppColors.border.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
