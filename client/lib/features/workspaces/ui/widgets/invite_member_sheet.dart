import 'package:client/core/dialog/app_bottom_sheet.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:client/core/widgets/app_button.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InviteMemberSheet extends StatefulWidget {
  const InviteMemberSheet({super.key});

  static Future<void> show(BuildContext context) {
    final cubit = context.read<WorkspaceSettingsCubit>();
    return showAppBottomSheet(
      context: context,
      builder: (_) =>
          BlocProvider.value(value: cubit, child: const InviteMemberSheet()),
    );
  }

  @override
  State<InviteMemberSheet> createState() => _InviteMemberSheetState();
}

class _InviteMemberSheetState extends State<InviteMemberSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.sm,
        AppSpacing.xxl,
        AppSpacing.xxl,
      ),
      child: BlocConsumer<WorkspaceSettingsCubit, WorkspaceSettingsState>(
        listener: (context, state) {
          if (state is WorkspaceSettingsLoaded &&
              (state.successAction is ActionMemberAdded ||
                  state.successAction is ActionMemberAddedWithEmail)) {
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          final isInviting =
              state is WorkspaceSettingsLoaded && state.isInviting;

          return Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppSheetDragHandle(),
                AppSpacing.gapHLg,
                Text(
                  l10n.inviteMember,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.gapHXs,
                Text(
                  l10n.inviteMemberSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                AppSpacing.gapHXxl,
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    hintText: l10n.emailPlaceholder,
                    prefixIcon: const Icon(
                      Icons.mail_outline_rounded,
                      size: AppIconSize.lg,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.emailRequired;
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return l10n.invalidEmail;
                    }
                    return null;
                  },
                ),
                AppSpacing.gapHXxl,
                AppButton(
                  label: l10n.addMember,
                  isLoading: isInviting,
                  variant: AppButtonVariant.primary,
                  onPressed: isInviting
                      ? null
                      : () {
                          if (_formKey.currentState?.validate() ?? false) {
                            context.read<WorkspaceSettingsCubit>().inviteMember(
                              _emailController.text.trim(),
                            );
                          }
                        },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
