import '../../offers/domain/offer.dart';
import '../domain/transaction_model.dart';
import '../domain/transaction_repository.dart';

/// TEMPORARY stand-in for Firestore, same idea as FakeWalletRepository.
/// Once we're ready, we add transaction_firestore_repository.dart
/// implementing this same contract, and swap one line in main.dart.
class FakeTransactionRepository implements TransactionRepository {
  final Map<String, TransactionModel> _fakeDb = {};
  int _counter = 0;

  @override
  Future<TransactionModel> createFromOffer(Offer offer) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _counter++;
    final transaction = TransactionModel(
      id: 'txn_$_counter',
      offerId: offer.id,
      buyerId: offer.buyerId,
      farmerId: offer.farmerId,
      amount: offer.pricePerKg * offer.quantityKg,
      escrowStatus: 'held',
      deliveryConfirmed: false,
      createdAt: DateTime.now(),
    );
    _fakeDb[transaction.id] = transaction;
    return transaction;
  }

  @override
  Future<void> confirmDelivery(String transactionId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final current = _fakeDb[transactionId];
    if (current == null) {
      throw Exception('Transaction not found: $transactionId');
    }
    _fakeDb[transactionId] = current.copyWith(
      escrowStatus: 'released',
      deliveryConfirmed: true,
    );
  }

  @override
  Future<TransactionModel> getTransaction(String transactionId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final transaction = _fakeDb[transactionId];
    if (transaction == null) {
      throw Exception('Transaction not found: $transactionId');
    }
    return transaction;
  }
}

/// A sample fake Offer, just for testing this screen today, before real
/// offers flow from Dorcas's feature into this one. Uses the exact same
/// Offer class she wrote, so nothing needs to change once they're connected.
final fakeAcceptedOffer = Offer(
  id: 'offer_demo_1',
  listingId: 'listing_demo_1',
  buyerId: 'demo-buyer',
  farmerId: 'demo-farmer',
  pricePerKg: 500,
  quantityKg: 20,
  status: 'accepted',
  createdAt: DateTime.now(),
);
