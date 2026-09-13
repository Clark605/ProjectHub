import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/theme/workspace_accent.dart';
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
  String? _selectedAccent;
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
      _selectedAccent = state.workspace.accentColor;
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

        final role = state.workspace.membership?.role ?? '';
        final isOwner = role.toLowerCase() == 'owner';
        final activeAccentId = _selectedAccent ?? state.workspace.accentColor;

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
                if (isOwner) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(
                        Icons.palette_outlined,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Accent Color',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Subtle wayfinding color for workspace indicators and tabs.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: WorkspaceAccent.values.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final accent = WorkspaceAccent.values[index];
                        final isSelected = activeAccentId == accent.id;
                        final color = accent.resolvedColor(theme.brightness);
                        return Tooltip(
                          message: accent.name,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedAccent = accent.id;
                              });
                            },
                            borderRadius: BorderRadius.circular(22),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                                border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.onSurface
                                      : Colors.transparent,
                                  width: isSelected ? 2.5 : 0,
                                ),
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check_rounded,
                                      color: accent.resolvedOnAccent(theme.brightness),
                                      size: 20,
                                    )
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
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
                                    activeAccentId,
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
