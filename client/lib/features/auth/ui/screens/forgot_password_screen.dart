import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/utils/validators.dart';
import 'package:client/core/widgets/ambient_glow_background.dart';
import 'package:client/core/widgets/app_button.dart';
import 'package:client/core/widgets/app_text_field.dart';
import 'package:client/features/auth/cubit/forgot_password_cubit.dart';
import 'package:client/features/auth/cubit/forgot_password_state.dart';
import 'package:client/features/auth/ui/widgets/auth_back_to_login_link.dart';
import 'package:client/features/auth/ui/widgets/auth_error_banner.dart';
import 'package:client/features/auth/ui/widgets/auth_header.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSendCode(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    context.read<ForgotPasswordCubit>().sendResetCode(
          email: _emailController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => getIt<ForgotPasswordCubit>(),
      child: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
        listener: (context, state) {
          state.whenOrNull(
            success: (response) {
              Navigator.pushNamed(
                context,
                RouteNames.resetPassword,
                arguments: _emailController.text.trim(),
              );
            },
          );
        },
        builder: (context, state) {
          final isLoading = state.maybeWhen(
            loading: () => true,
            orElse: () => false,
          );
          final errorMessage = state.whenOrNull(
            failure: (msg) => msg,
          );

          return AbsorbPointer(
            absorbing: isLoading,
            child: AmbientGlowBackground(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.maybePop(context),
                    tooltip:
                        MaterialLocalizations.of(context).backButtonTooltip,
                  ),
                ),
                body: SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AuthHeader(
                                title: l10n.forgotPasswordTitle,
                                subtitle: l10n.forgotPasswordSubtitle,
                              ),
                              const SizedBox(height: 24),
                              AuthErrorBanner(errorMessage: errorMessage),
                              const SizedBox(height: 12),
                              AppTextField(
                                label: l10n.email,
                                hintText: l10n.emailPlaceholder,
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.done,
                                prefixIcon: Icons.mail_outline_rounded,
                                onFieldSubmitted: (_) => _onSendCode(context),
                                validator: (val) =>
                                    FormValidators.email(val, l10n),
                              )
                                  .animate()
                                  .fadeIn(duration: 400.ms, delay: 200.ms)
                                  .slideY(begin: 0.1, end: 0),
                              const SizedBox(height: 24),
                              AppButton(
                                label: l10n.sendResetCode,
                                variant: AppButtonVariant.primary,
                                isLoading: isLoading,
                                onPressed: () => _onSendCode(context),
                              )
                                  .animate()
                                  .fadeIn(duration: 400.ms, delay: 300.ms)
                                  .slideY(begin: 0.1, end: 0),
                              const SizedBox(height: 28),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      RouteNames.resetPassword,
                                      arguments: _emailController.text.trim(),
                                    );
                                  },
                                  child: Text(
                                    l10n.haveResetCode,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppColors.skyBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                                  .animate()
                                  .fadeIn(duration: 400.ms, delay: 350.ms),
                              const SizedBox(height: 16),
                              const AuthBackToLoginLink(delayMs: 400),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
