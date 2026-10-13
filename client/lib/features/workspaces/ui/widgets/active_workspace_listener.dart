import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_context_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Listens for active workspace ID transitions in [WorkspaceContextCubit]
/// and triggers [onWorkspaceChanged] only when the active workspace ID changes.
class ActiveWorkspaceListener extends StatelessWidget {
  final void Function(BuildContext context, int? activeWorkspaceId)
      onWorkspaceChanged;
  final Widget child;

  const ActiveWorkspaceListener({
    super.key,
    required this.onWorkspaceChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<WorkspaceContextCubit, WorkspaceContextState>(
      listenWhen: (previous, current) =>
          previous.activeWorkspaceId != current.activeWorkspaceId,
      listener: (context, state) =>
          onWorkspaceChanged(context, state.activeWorkspaceId),
      child: child,
    );
  }
}

