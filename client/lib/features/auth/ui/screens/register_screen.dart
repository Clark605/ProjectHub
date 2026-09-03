import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/core/utils/validators.dart';
import 'package:client/core/widgets/ambient_glow_background.dart';
import 'package:client/core/widgets/app_button.dart';
import 'package:client/core/widgets/app_text_field.dart';
import 'package:client/features/auth/cubit/register_cubit.dart';
import 'package:client/features/auth/cubit/register_state.dart';
import 'package:client/features/auth/ui/widgets/auth_error_banner.dart';
import 'package:client/features/auth/ui/widgets/auth_footer_link.dart';
import 'package:client/features/auth/ui/widgets/auth_header.dart';
import 'package:client/features/auth/ui/widgets/social_auth_buttons.dart';
import 'package:client/features/auth/ui/widgets/terms_checkbox.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _agreeToTerms = false;
  bool _termsError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSignUp(BuildContext context) {
    setState(() => _termsError = !_agreeToTerms);
    if (!_formKey.currentState!.validate() || !_agreeToTerms) return;

    context.read<RegisterCubit>().register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => getIt<RegisterCubit>(),
      child: BlocConsumer<RegisterCubit, RegisterState>(
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
          final errorMessage = state.whenOrNull(failure: (msg) => msg);

          return AbsorbPointer(
            absorbing: isLoading,
            child: AmbientGlowBackground(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 36,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 8),
                              AuthHeader(
                                title: l10n.createAccount,
                                subtitle: l10n.createAccountSubtitle,
                              ),
                              const SizedBox(height: 24),
                              AuthErrorBanner(errorMessage: errorMessage),
                              const SizedBox(height: 12),
                              AppTextField(
                                    label: l10n.fullName,
                                    hintText: l10n.fullNamePlaceholder,
                                    controller: _nameController,
                                    keyboardType: TextInputType.name,
                                    textInputAction: TextInputAction.next,
                                    validator: (val) =>
                                        FormValidators.requiredField(
                                          val,
                                          l10n.nameRequired,
                                        ),
                                  )
                                  .animate()
                                  .fadeIn(duration: 400.ms, delay: 200.ms)
                                  .slideY(begin: 0.1, end: 0),
                              const SizedBox(height: 18),
                              AppTextField(
                                    label: l10n.email,
                                    hintText: l10n.emailPlaceholder,
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    validator: (val) =>
                                        FormValidators.email(val, l10n),
                                  )
                                  .animate()
                                  .fadeIn(duration: 400.ms, delay: 250.ms)
                                  .slideY(begin: 0.1, end: 0),
                              const SizedBox(height: 18),
                              AppTextField(
                                    label: l10n.password,
                                    hintText: l10n.passwordPlaceholder,
                                    controller: _passwordController,
                                    isPassword: true,
                                    textInputAction: TextInputAction.next,
                                    validator: (val) =>
                                        FormValidators.password(val, l10n),
                                  )
                                  .animate()
                                  .fadeIn(duration: 400.ms, delay: 300.ms)
                                  .slideY(begin: 0.1, end: 0),
                              const SizedBox(height: 18),
                              AppTextField(
                                    label: l10n.confirmPassword,
                                    hintText: l10n.passwordPlaceholder,
                                    controller: _confirmPasswordController,
                                    isPassword: true,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _onSignUp(context),
                                    validator: (val) =>
                                        FormValidators.confirmPassword(
                                          val,
                                          _passwordController.text,
                                          l10n,
                                        ),
                                  )
                                  .animate()
                                  .fadeIn(duration: 400.ms, delay: 350.ms)
                                  .slideY(begin: 0.1, end: 0),
                              const SizedBox(height: 16),
                              TermsCheckbox(
                                value: _agreeToTerms,
                                hasError: _termsError,
                                onChanged: (val) {
                                  setState(() {
                                    _agreeToTerms = val ?? false;
                                    if (_agreeToTerms) _termsError = false;
                                  });
                                },
                              ),
                              const SizedBox(height: 24),
                              AppButton(
                                    label: l10n.signUp,
                                    variant: AppButtonVariant.primary,
                                    isLoading: isLoading,
                                    onPressed: () => _onSignUp(context),
                                  )
                                  .animate()
                                  .fadeIn(duration: 400.ms, delay: 450.ms)
                                  .slideY(begin: 0.1, end: 0),
                              const SizedBox(height: 24),
                              SocialAuthSection(
                                    onGooglePressed: () {
                                      // TODO: Implement Google Auth
                                    },
                                    onGithubPressed: () {
                                      // TODO: Implement GitHub Auth
                                    },
                                  )
                                  .animate()
                                  .fadeIn(duration: 400.ms, delay: 500.ms)
                                  .slideY(begin: 0.1, end: 0),
                              const SizedBox(height: 32),
                              AuthFooterLink(
                                promptText: l10n.alreadyHaveAccount,
                                actionText: l10n.signIn,
                                onTap: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    RouteNames.login,
                                  );
                                },
                                delayMs: 550,
                              ),
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
