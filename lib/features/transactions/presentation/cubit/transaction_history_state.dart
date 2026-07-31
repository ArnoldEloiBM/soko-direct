import 'package:equatable/equatable.dart';

import '../../domain/entities/app_transaction.dart';

enum TransactionHistoryStatus { loading, loaded, error }

class TransactionHistoryState extends Equatable {
  const TransactionHistoryState({
    this.status = TransactionHistoryStatus.loading,
    this.transactions = const [],
    this.errorMessage,
  });

  final TransactionHistoryStatus status;
  final List<AppTransaction> transactions;
  final String? errorMessage;

  TransactionHistoryState copyWith({
    TransactionHistoryStatus? status,
    List<AppTransaction>? transactions,
    String? errorMessage,
  }) {
    return TransactionHistoryState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, transactions, errorMessage];
}
