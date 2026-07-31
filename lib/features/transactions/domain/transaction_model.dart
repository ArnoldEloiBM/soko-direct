/// One transaction created once an Offer is accepted.
/// Matches the ERD:
///   Transaction: id, amount, escrowStatus, deliveryConfirmed
/// and links back to the Offer it came from (see Dorcas's Offer model
/// at lib/features/offers/domain/offer.dart).
///
/// escrowStatus values: "held" (payment held, waiting for delivery)
///                       "released" (delivery confirmed, farmer paid)
class TransactionModel {
  final String id;
  final String offerId;
  final String buyerId;
  final String farmerId;
  final double amount;
  final String escrowStatus;
  final bool deliveryConfirmed;
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.offerId,
    required this.buyerId,
    required this.farmerId,
    required this.amount,
    required this.escrowStatus,
    required this.deliveryConfirmed,
    required this.createdAt,
  });

  factory TransactionModel.fromMap(String id, Map<String, dynamic> map) {
    return TransactionModel(
      id: id,
      offerId: map['offerId'] as String,
      buyerId: map['buyerId'] as String,
      farmerId: map['farmerId'] as String,
      amount: (map['amount'] as num).toDouble(),
      escrowStatus: map['escrowStatus'] as String,
      deliveryConfirmed: map['deliveryConfirmed'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'offerId': offerId,
      'buyerId': buyerId,
      'farmerId': farmerId,
      'amount': amount,
      'escrowStatus': escrowStatus,
      'deliveryConfirmed': deliveryConfirmed,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  TransactionModel copyWith({
    String? escrowStatus,
    bool? deliveryConfirmed,
  }) {
    return TransactionModel(
      id: id,
      offerId: offerId,
      buyerId: buyerId,
      farmerId: farmerId,
      amount: amount,
      escrowStatus: escrowStatus ?? this.escrowStatus,
      deliveryConfirmed: deliveryConfirmed ?? this.deliveryConfirmed,
      createdAt: createdAt,
    );
  }
}
