import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/role/role_cubit.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../transactions/presentation/screens/transaction_history_screen.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

/// Placeholder landing screen shown right after login/registration.
/// Proves the auth + logout + navigation wiring works end to end;
/// replace `body` with the real Farmer/Buyer dashboard once it exists.
class SignedInHome extends StatelessWidget {
  const SignedInHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state.user;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Soko Direct'),
            actions: [
              IconButton(
                icon: const Icon(Icons.brightness_6),
                tooltip: 'Toggle theme',
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: () => context.read<AuthCubit>().logout(),
              ),
            ],
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome, ${user?.name ?? ''}',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.role == UserRole.farmer
                        ? 'Farmer account'
                        : 'Buyer account',
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    icon: const Icon(Icons.receipt_long_outlined),
                    label: const Text('View transaction history'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TransactionHistoryScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
