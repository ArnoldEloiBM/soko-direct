import '../../offers/domain/offer.dart';
import 'transaction_model.dart';

abstract class TransactionRepository {
  /// Creates a new Transaction from an accepted Offer.
  /// escrowStatus starts as "held" (payment held, waiting for delivery).
  Future<TransactionModel> createFromOffer(Offer offer);

  /// Marks delivery as confirmed and releases escrow to the farmer.
  Future<void> confirmDelivery(String transactionId);

  Future<TransactionModel> getTransaction(String transactionId);
}
