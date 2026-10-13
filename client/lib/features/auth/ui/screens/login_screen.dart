import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:client/core/utils/validators.dart';
import 'package:client/core/widgets/app_button.dart';
import 'package:client/core/widgets/app_error_banner.dart';
import 'package:client/core/widgets/app_text_field.dart';
import 'package:client/features/auth/cubit/login_cubit.dart';
import 'package:client/features/auth/cubit/login_state.dart';
import 'package:client/features/auth/ui/widgets/auth_footer_link.dart';
import 'package:client/features/auth/ui/widgets/auth_header.dart';
import 'package:client/features/auth/ui/widgets/auth_screen_scaffold.dart';
import 'package:client/features/auth/ui/widgets/social_auth_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSignIn(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    context.read<LoginCubit>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  void _onGoogleSignIn(BuildContext context) {
    context.read<LoginCubit>().loginWithGoogle();
  }

  void _onGithubSignIn(BuildContext context) {
    context.read<LoginCubit>().loginWithGithub();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        state.whenOrNull(
          success: (_) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteNames.shell,
              (route) => false,
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
          failure: (failure) => failure.toLocalizedMessage(l10n),
        );

        return AuthScreenScaffold(
          isLoading: isLoading,
          formKey: _formKey,
          children: [
            AppSpacing.gapHMd,
            AuthHeader(
              title: l10n.welcomeBack,
              subtitle: l10n.welcomeBackSubtitle,
            ),
            AppSpacing.gapHXxl,
            AppErrorBanner(errorMessage: errorMessage),
            AppSpacing.gapHMd,
            AppTextField(
                  label: l10n.email,
                  hintText: l10n.emailPlaceholder,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (val) => FormValidators.email(val, l10n),
                )
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
                  label: l10n.password,
                  hintText: l10n.passwordPlaceholder,
                  controller: _passwordController,
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _onSignIn(context),
                  validator: (val) => FormValidators.password(val, l10n),
                )
                .animate()
                .fadeIn(duration: 400.ms, delay: 250.ms)
                .slideY(begin: 0.1, end: 0),
            AppSpacing.gapHMd,
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, RouteNames.forgotPassword);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.forgotPassword,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.skyBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
            AppSpacing.gapHXxl,
            AppButton(
                  label: l10n.signIn,
                  variant: AppButtonVariant.primary,
                  isLoading: isLoading,
                  onPressed: () => _onSignIn(context),
                )
                .animate()
                .fadeIn(duration: 400.ms, delay: 350.ms)
                .slideY(begin: 0.1, end: 0),
            AppSpacing.gapHXxl,
            SocialAuthSection(
                  onGooglePressed: () => _onGoogleSignIn(context),
                  onGithubPressed: () => _onGithubSignIn(context),
                )
                .animate()
                .fadeIn(duration: 400.ms, delay: 400.ms)
                .slideY(begin: 0.1, end: 0),
            AppSpacing.gapHXxxl,
            AuthFooterLink(
              promptText: l10n.dontHaveAccount,
              actionText: l10n.signUp,
              onTap: () {
                Navigator.pushReplacementNamed(context, RouteNames.register);
              },
            ),
          ],
        );
      },
    );
  }
}
