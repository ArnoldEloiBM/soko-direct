import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../listings/presentation/main_shell.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'login_screen.dart';

/// Decides what the app shows based on auth status: pushed from
/// SplashScreen for returning users (role already chosen), or from
/// RoleScreen right after a first-time user picks Farmer/Buyer.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state.status == AuthStatus.authenticated && state.user != null) {
          return const MainShell();
        }
        return const LoginScreen();
      },
    );
  }
}
