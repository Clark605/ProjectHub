import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/widgets/ambient_glow_background.dart';
import 'package:client/core/widgets/app_button.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_context_state.dart';
import 'package:client/features/workspaces/ui/widgets/quick_start_dialog.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class WorkspacesScreen extends StatefulWidget {
  const WorkspacesScreen({super.key});

  @override
  State<WorkspacesScreen> createState() => _WorkspacesScreenState();
}

class _WorkspacesScreenState extends State<WorkspacesScreen> {
  @override
  void initState() {
    super.initState();
    getIt<WorkspaceContextCubit>().loadWorkspaces();
  }

  void _navigateToShell() {
    Navigator.of(context).pushReplacementNamed(RouteNames.shell);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: getIt<WorkspaceContextCubit>(),
      child: BlocConsumer<WorkspaceContextCubit, WorkspaceContextState>(
        listener: (context, state) {
          state.whenOrNull(
            loaded: (workspaces, activeWorkspace) => _navigateToShell(),
            empty: () =>
                QuickStartDialog.show(context, onSuccess: _navigateToShell),
          );
        },
        builder: (context, state) {
          return AmbientGlowBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: state.maybeWhen(
                  error: (msg) => Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          msg,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 180),
                          child: AppButton(
                            label: l10n.retry,
                            icon: Icons.refresh_rounded,
                            onPressed: () =>
                                getIt<WorkspaceContextCubit>().loadWorkspaces(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  orElse: () =>
                      const CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
