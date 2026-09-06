import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/widgets/app_danger_zone.dart';
import 'package:client/features/projects/cubit/project_detail_cubit.dart';
import 'package:client/features/projects/cubit/project_detail_state.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class ProjectDangerZone extends StatelessWidget {
  final bool canDelete;

  const ProjectDangerZone({super.key, required this.canDelete});

  @override
  Widget build(BuildContext context) {
    if (!canDelete) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<ProjectDetailCubit, ProjectDetailState>(
      builder: (context, state) {
        if (state is! ProjectDetailLoaded) return const SizedBox.shrink();

        return AppDangerZone(
          title: l10n.dangerZone,
          description: l10n.deleteProjectWarning,
          entityName: state.project.name,
          onDelete: () {
            if (!state.isDeleting) {
              context.read<ProjectDetailCubit>().deleteProject();
            }
          },
        );
      },
    );
  }
}
