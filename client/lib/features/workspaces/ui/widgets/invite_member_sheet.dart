import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/widgets/app_button.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_state.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class InviteMemberSheet extends StatefulWidget {
  const InviteMemberSheet({super.key});

  static Future<void> show(BuildContext context) {
    final cubit = context.read<WorkspaceSettingsCubit>();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.inviteMember,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.inviteMemberSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    hintText: l10n.emailPlaceholder,
                    prefixIcon: const Icon(
                      Icons.mail_outline_rounded,
                      size: 20,
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
                const SizedBox(height: 28),
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
