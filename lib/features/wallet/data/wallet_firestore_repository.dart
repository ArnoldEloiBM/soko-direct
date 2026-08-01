import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/wallet_model.dart';
import '../domain/wallet_repository.dart';

/// Real Firestore implementation.
/// Collection: "wallets"
/// Document ID: the user's userId (one wallet per user).
///
/// Same contract as FakeWalletRepository, so WalletCubit and WalletScreen
/// don't need to change at all — only main.dart's wiring changes.
class WalletFirestoreRepository implements WalletRepository {
  final _walletsRef = FirebaseFirestore.instance.collection('wallets');

  @override
  Future<WalletModel> getWallet(String userId) async {
    final doc = await _walletsRef.doc(userId).get();

    if (!doc.exists) {
      // First time this user opens their wallet — create a starting one.
      final starter = WalletModel(userId: userId, balance: 0, provider: 'MTN');
      await _walletsRef.doc(userId).set(starter.toMap());
      return starter;
    }

    return WalletModel.fromMap(userId, doc.data()!);
  }

  @override
  Future<void> updateBalance(String userId, double newBalance) async {
    await _walletsRef.doc(userId).update({'balance': newBalance});
  }
}
