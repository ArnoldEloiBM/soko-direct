import '../entities/app_transaction.dart';

/// Read side of the transactions feature (this PR only implements
/// "View transaction history"). Whoever builds "Confirm a transaction"
/// / "Confirm delivery" should add their write methods to this same
/// interface rather than creating a second repository for the
/// `transactions` collection.
abstract class TransactionRepository {
  /// Live list of every transaction the user is party to (as buyer or
  /// farmer), newest first. A stream (not a one-off fetch) so the
  /// history screen updates immediately when a transaction changes.
  Stream<List<AppTransaction>> watchHistory(String userId);
}
