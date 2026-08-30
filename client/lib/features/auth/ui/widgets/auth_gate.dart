import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/core/di/injection.dart';
import 'package:client/core/widgets/ambient_glow_background.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/auth/cubit/app_auth_state.dart';
import 'package:client/features/auth/ui/screens/login_screen.dart';

class AuthGate extends StatelessWidget {
  final Widget authenticatedChild;

  const AuthGate({super.key, required this.authenticatedChild});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AppAuthCubit>(),
      child: BlocBuilder<AppAuthCubit, AppAuthState>(
        builder: (context, state) {
          return state.when(
            initial: () => const AmbientGlowBackground(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(child: CircularProgressIndicator()),
              ),
            ),
            authenticated: (_) => authenticatedChild,
            unauthenticated: () => const LoginScreen(),
          );
        },
      ),
    );
  }
}
