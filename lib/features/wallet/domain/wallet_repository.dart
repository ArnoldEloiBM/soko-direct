import 'wallet_model.dart';

/// The Cubit only ever talks to THIS abstract contract.
/// It doesn't know or care whether the real implementation is
/// Firestore or a fake in-memory version — that's the whole point.
abstract class WalletRepository {
  Future<WalletModel> getWallet(String userId);
  Future<void> updateBalance(String userId, double newBalance);
}
