import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/fake_transaction_repository.dart';
import 'transaction_cubit.dart';
import 'transaction_state.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  @override
  void initState() {
    super.initState();
    // In real use, this offer comes from Dorcas's "accept offer" flow.
    // For now we use the fake accepted offer to build and test this screen.
    context.read<TransactionCubit>().startTransaction(fakeAcceptedOffer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction')),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading || state is TransactionInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TransactionError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Something went wrong: ${state.message}'),
              ),
            );
          }

          final txn = (state as TransactionLoaded).transaction;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Amount: ${txn.amount.toStringAsFixed(0)} RWF',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('Escrow status: ${txn.escrowStatus}'),
                const SizedBox(height: 8),
                Text(
                  txn.deliveryConfirmed
                      ? 'Delivery confirmed ✅'
                      : 'Waiting for delivery confirmation',
                ),
                const SizedBox(height: 24),
                if (!txn.deliveryConfirmed)
                  ElevatedButton(
                    onPressed: () =>
                        context.read<TransactionCubit>().confirmDelivery(),
                    child: const Text('Confirm Delivery'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
