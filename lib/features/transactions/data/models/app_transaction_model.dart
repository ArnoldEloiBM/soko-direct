import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/app_transaction.dart';

class AppTransactionModel extends AppTransaction {
  const AppTransactionModel({
    required super.id,
    required super.listingId,
    required super.buyerId,
    required super.farmerId,
    required super.cropType,
    required super.amount,
    required super.escrowStatus,
    required super.deliveryConfirmed,
    required super.createdAt,
  });

  factory AppTransactionModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? const {};
    return AppTransactionModel(
      id: doc.id,
      listingId: data['listingId'] as String? ?? '',
      buyerId: data['buyerId'] as String? ?? '',
      farmerId: data['farmerId'] as String? ?? '',
      cropType: data['cropType'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      escrowStatus: _escrowStatusFromString(data['escrowStatus'] as String?),
      deliveryConfirmed: data['deliveryConfirmed'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static EscrowStatus _escrowStatusFromString(String? value) {
    return EscrowStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => EscrowStatus.pending,
    );
  }
}
