import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/presentation/cubit/auth_cubit.dart';
import 'wallet_cubit.dart';
import 'wallet_state.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  // Falls back to this only if somehow reached while signed out — AuthGate
  // should prevent that in practice.
  static const demoUserId = 'demo-user';

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  late final String _userId;

  @override
  void initState() {
    super.initState();
    _userId =
        context.read<AuthCubit>().state.user?.id ?? WalletScreen.demoUserId;
    // Load the wallet the moment this screen appears.
    context.read<WalletCubit>().loadWallet(_userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: BlocBuilder<WalletCubit, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading || state is WalletInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WalletError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Something went wrong: ${state.message}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final wallet = (state as WalletLoaded).wallet;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Provider: ${wallet.provider}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${wallet.balance.toStringAsFixed(0)} RWF',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.read<WalletCubit>().topUp(
                    WalletScreen.demoUserId,
                    1000,
                  ),
                  child: const Text('Top Up 1000 RWF'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
