import 'package:flutter_bloc/flutter_bloc.dart';
import '../../offers/domain/offer.dart';
import '../domain/transaction_repository.dart';
import 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  final TransactionRepository _repository;

  TransactionCubit(this._repository) : super(TransactionInitial());

  /// Call this once a buyer's offer has been accepted by the farmer.
  Future<void> startTransaction(Offer acceptedOffer) async {
    emit(TransactionLoading());
    try {
      final transaction = await _repository.createFromOffer(acceptedOffer);
      emit(TransactionLoaded(transaction));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  /// Call this when the buyer confirms they received the goods.
  /// Releases escrow to the farmer.
  Future<void> confirmDelivery() async {
    final currentState = state;
    if (currentState is! TransactionLoaded) return;

    try {
      await _repository.confirmDelivery(currentState.transaction.id);
      final updated = await _repository.getTransaction(currentState.transaction.id);
      emit(TransactionLoaded(updated));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }
}
