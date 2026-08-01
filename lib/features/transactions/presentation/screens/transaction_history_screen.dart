import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/repositories/firebase_transaction_repository.dart';
import '../cubit/transaction_history_cubit.dart';
import '../cubit/transaction_history_state.dart';
import '../widgets/transaction_tile.dart';

/// Self-contained screen: push it from anywhere with
/// `Navigator.push(MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()))`
/// — it reads the signed-in user from `AuthCubit` and creates its own
/// `TransactionHistoryCubit`, so callers don't need to wire anything.
class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthCubit>().state.user?.id;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transaction History')),
        body: const Center(child: Text('Please log in to view your history.')),
      );
    }

    return BlocProvider(
      create: (_) => TransactionHistoryCubit(
        transactionRepository: FirebaseTransactionRepository(),
        userId: userId,
      ),
      child: _TransactionHistoryView(userId: userId),
    );
  }
}

class _TransactionHistoryView extends StatelessWidget {
  const _TransactionHistoryView({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: BlocBuilder<TransactionHistoryCubit, TransactionHistoryState>(
        builder: (context, state) {
          switch (state.status) {
            case TransactionHistoryStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case TransactionHistoryStatus.error:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    state.errorMessage ?? 'Something went wrong.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            case TransactionHistoryStatus.loaded:
              if (state.transactions.isEmpty) {
                return const Center(child: Text('No transactions yet.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.transactions.length,
                itemBuilder: (context, index) => TransactionTile(
                  transaction: state.transactions[index],
                  currentUserId: userId,
                ),
              );
          }
        },
      ),
    );
  }
}
