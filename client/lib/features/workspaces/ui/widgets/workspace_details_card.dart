import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/widgets/app_button.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_state.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class WorkspaceDetailsCard extends StatefulWidget {
  const WorkspaceDetailsCard({super.key});

  @override
  State<WorkspaceDetailsCard> createState() => _WorkspaceDetailsCardState();
}

class _WorkspaceDetailsCardState extends State<WorkspaceDetailsCard> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  int? _lastWorkspaceId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _syncControllers(WorkspaceSettingsLoaded state) {
    if (_lastWorkspaceId != state.workspace.id) {
      _nameController.text = state.workspace.name;
      _descController.text = state.workspace.description;
      _lastWorkspaceId = state.workspace.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocConsumer<WorkspaceSettingsCubit, WorkspaceSettingsState>(
      listener: (context, state) {
        if (state is WorkspaceSettingsLoaded) {
          _syncControllers(state);
        }
      },
      builder: (context, state) {
        if (state is! WorkspaceSettingsLoaded) return const SizedBox.shrink();
        _syncControllers(state);

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.workspaceDetails,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.workspaceName,
                    hintText: l10n.workspaceNamePlaceholder,
                    prefixIcon: const Icon(Icons.business_rounded, size: 20),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.workspaceNameRequired;
                    }
                    if (value.trim().length > 100) {
                      return l10n.workspaceNameTooLong;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: l10n.workspaceDescription,
                    hintText: l10n.workspaceDescriptionPlaceholder,
                    alignLabelWithHint: true,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 48),
                      child: Icon(Icons.description_outlined, size: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: AppButton(
                    label: l10n.saveDetails,
                    icon: Icons.check_rounded,
                    isLoading: state.isSaving,
                    isExpanded: false,
                    variant: AppButtonVariant.primary,
                    onPressed: state.isSaving
                        ? null
                        : () {
                            if (_formKey.currentState?.validate() ?? false) {
                              context
                                  .read<WorkspaceSettingsCubit>()
                                  .updateDetails(
                                    _nameController.text.trim(),
                                    _descController.text.trim(),
                                  );
                            }
                          },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
