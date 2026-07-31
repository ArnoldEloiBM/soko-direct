import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/app_transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../models/app_transaction_model.dart';

/// Reads `transactions/{id}` documents. Expects each document to include
/// a `participants: [buyerId, farmerId]` array field (in addition to the
/// separate `buyerId`/`farmerId` fields) — Firestore can't OR-query two
/// different fields, so whoever writes a transaction must also write
/// this array for `watchHistory` to find it via `arrayContains`.
///
/// Note: combining `arrayContains` with `orderBy` requires a composite
/// index; Firestore will log a console link to create it the first time
/// this query runs against a real project.
class FirebaseTransactionRepository implements TransactionRepository {
  FirebaseTransactionRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<AppTransaction>> watchHistory(String userId) {
    return _firestore
        .collection('transactions')
        .where('participants', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(AppTransactionModel.fromDoc).toList(),
        );
  }
}
