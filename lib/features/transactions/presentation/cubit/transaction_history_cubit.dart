import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import 'transaction_history_state.dart';

class TransactionHistoryCubit extends Cubit<TransactionHistoryState> {
  TransactionHistoryCubit({
    required TransactionRepository transactionRepository,
    required String userId,
  }) : super(const TransactionHistoryState()) {
    _subscription = transactionRepository
        .watchHistory(userId)
        .listen(
          (transactions) => emit(
            state.copyWith(
              status: TransactionHistoryStatus.loaded,
              transactions: transactions,
            ),
          ),
          onError: (_) => emit(
            state.copyWith(
              status: TransactionHistoryStatus.error,
              errorMessage:
                  'Could not load your transaction history. Check your connection and try again.',
            ),
          ),
        );
  }

  late final StreamSubscription<List<AppTransaction>> _subscription;

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
