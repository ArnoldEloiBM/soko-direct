import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'login_screen.dart';
import 'signed_in_home.dart';

/// Decides what the app shows based on auth status.
///
/// Temporary entry point: once onboarding/role-selection (splash) screens
/// exist, this should be pushed from there instead of being `app.dart`'s
/// `home` directly.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state.status == AuthStatus.authenticated && state.user != null) {
          return const SignedInHome();
        }
        return const LoginScreen();
      },
    );
  }
}
