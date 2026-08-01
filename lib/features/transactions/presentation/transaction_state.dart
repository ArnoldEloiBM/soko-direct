import 'package:equatable/equatable.dart';
import '../domain/transaction_model.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final TransactionModel transaction;
  const TransactionLoaded(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class TransactionError extends TransactionState {
  final String message;
  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}
