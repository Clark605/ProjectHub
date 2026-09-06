import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/core/utils/validators.dart';
import 'package:client/core/widgets/app_button.dart';
import 'package:client/core/widgets/app_error_banner.dart';
import 'package:client/core/widgets/app_snackbar.dart';
import 'package:client/core/widgets/app_text_field.dart';
import 'package:client/features/auth/cubit/reset_password_cubit.dart';
import 'package:client/features/auth/cubit/reset_password_state.dart';
import 'package:client/features/auth/ui/widgets/auth_back_to_login_link.dart';
import 'package:client/features/auth/ui/widgets/auth_header.dart';
import 'package:client/features/auth/ui/widgets/auth_screen_scaffold.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final _tokenController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onResetPassword(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    context.read<ResetPasswordCubit>().resetPassword(
          email: _emailController.text.trim(),
          token: _tokenController.text.trim(),
          newPassword: _newPasswordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<ResetPasswordCubit>(),
      child: BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
        listener: (context, state) {
          state.whenOrNull(
            success: () {
              context.showSuccessSnackBar(l10n.passwordResetSuccess);

              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteNames.login,
                (route) => false,
              );
            },
          );
        },
        builder: (context, state) {
          final isLoading = state.maybeWhen(loading: () => true, orElse: () => false);
          final errorMessage = state.whenOrNull(failure: (msg) => msg);

          return AuthScreenScaffold(
            isLoading: isLoading,
            formKey: _formKey,
            children: [
              AuthHeader(
                title: l10n.resetPasswordTitle,
                subtitle: l10n.resetPasswordSubtitle,
              ),
              const SizedBox(height: 24),
              AppErrorBanner(errorMessage: errorMessage),
              const SizedBox(height: 12),
              AppTextField(
                label: l10n.email,
                hintText: l10n.emailPlaceholder,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.mail_outline_rounded,
                validator: (val) => FormValidators.email(val, l10n),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(height: 18),
              AppTextField(
                label: l10n.resetToken,
                hintText: l10n.resetTokenPlaceholder,
                controller: _tokenController,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.vpn_key_outlined,
                validator: (val) => FormValidators.requiredField(val, l10n.tokenRequired),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 250.ms)
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(height: 18),
              AppTextField(
                label: l10n.newPassword,
                hintText: l10n.passwordPlaceholder,
                controller: _newPasswordController,
                isPassword: true,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.lock_outline_rounded,
                validator: (val) => FormValidators.password(val, l10n),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 300.ms)
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(height: 18),
              AppTextField(
                label: l10n.confirmNewPassword,
                hintText: l10n.passwordPlaceholder,
                controller: _confirmPasswordController,
                isPassword: true,
                textInputAction: TextInputAction.done,
                prefixIcon: Icons.lock_reset_rounded,
                onFieldSubmitted: (_) => _onResetPassword(context),
                validator: (val) => FormValidators.confirmPassword(val, _newPasswordController.text, l10n),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 350.ms)
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(height: 24),
              AppButton(
                label: l10n.resetPasswordButton,
                variant: AppButtonVariant.primary,
                isLoading: isLoading,
                onPressed: () => _onResetPassword(context),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 400.ms)
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(height: 28),
              const AuthBackToLoginLink(delayMs: 450),
            ],
          );
        },
      ),
    );
  }
}


