import 'package:equatable/equatable.dart';

/// Mirrors the ERD's Transaction node (child of Offer / Listing).
/// `held`/`released` reflect the escrow "payment held" -> "delivery
/// confirmed -> payment released" flow owned by the offers/transactions
/// creation screens — this feature only reads it.
enum EscrowStatus { pending, held, released, cancelled }

class AppTransaction extends Equatable {
  const AppTransaction({
    required this.id,
    required this.listingId,
    required this.buyerId,
    required this.farmerId,
    required this.cropType,
    required this.amount,
    required this.escrowStatus,
    required this.deliveryConfirmed,
    required this.createdAt,
  });

  final String id;
  final String listingId;
  final String buyerId;
  final String farmerId;
  final String cropType;
  final double amount;
  final EscrowStatus escrowStatus;
  final bool deliveryConfirmed;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    listingId,
    buyerId,
    farmerId,
    cropType,
    amount,
    escrowStatus,
    deliveryConfirmed,
    createdAt,
  ];
}
