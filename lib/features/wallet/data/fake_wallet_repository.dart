import '../domain/wallet_model.dart';
import '../domain/wallet_repository.dart';

/// TEMPORARY stand-in for Firestore, so the Wallet screen and Cubit can be
/// built and tested right now, before Firestore is live.
///
/// It behaves like a real backend: it "saves" data in memory and has a
/// small delay to mimic a network call, so the UI's loading states get
/// exercised properly too.
///
/// Once Firestore is ready, we add a new file:
///   wallet_firestore_repository.dart
/// implementing the same WalletRepository contract, then swap ONE line in
/// main.dart. Nothing in the Cubit or UI needs to change.
class FakeWalletRepository implements WalletRepository {
  // In-memory "database" — resets every time the app restarts.
  final Map<String, WalletModel> _fakeDb = {
    'demo-user': const WalletModel(
      userId: 'demo-user',
      balance: 15000, // RWF
      provider: 'MTN',
    ),
  };

  @override
  Future<WalletModel> getWallet(String userId) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // fake network delay
    final wallet = _fakeDb[userId];
    if (wallet == null) {
      throw Exception('Wallet not found for user $userId');
    }
    return wallet;
  }

  @override
  Future<void> updateBalance(String userId, double newBalance) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final current = _fakeDb[userId];
    if (current == null) {
      throw Exception('Wallet not found for user $userId');
    }
    _fakeDb[userId] = current.copyWith(balance: newBalance);
  }
}
