import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/wallet_repository.dart';
import 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  final WalletRepository _repository;

  // The Cubit receives its repository from outside (see main.dart) instead
  // of creating it itself. This is called "dependency injection" — it's
  // WHY we can swap Fake -> Real Firestore later without touching this file.
  WalletCubit(this._repository) : super(WalletInitial());

  Future<void> loadWallet(String userId) async {
    emit(WalletLoading());
    try {
      final wallet = await _repository.getWallet(userId);
      emit(WalletLoaded(wallet));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  Future<void> topUp(String userId, double amount) async {
    final currentState = state;
    if (currentState is! WalletLoaded) return; // nothing loaded yet, ignore

    try {
      final newBalance = currentState.wallet.balance + amount;
      await _repository.updateBalance(userId, newBalance);
      emit(WalletLoaded(currentState.wallet.copyWith(balance: newBalance)));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }
}
