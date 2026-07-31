import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/role/role_cubit.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../transactions/presentation/screens/transaction_history_screen.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

/// Body content for MainShell's "Profile" tab — account info, transaction
/// history, theme toggle, and logout. No Scaffold/AppBar of its own since
/// MainShell already provides the header chrome around every tab.
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state.user;
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              user?.name ?? '',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              user?.role == UserRole.farmer
                  ? 'Farmer account'
                  : 'Buyer account',
              textAlign: TextAlign.center,
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
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.brightness_6_outlined),
              label: const Text('Toggle theme'),
              onPressed: () => context.read<ThemeCubit>().toggleTheme(),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              onPressed: () => context.read<AuthCubit>().logout(),
            ),
          ],
        );
      },
    );
  }
}
