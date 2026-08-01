///One offer a buyer sends on a farmer's listing.
///Plain dart class, no Firebase here on purpose --
///same as rating.dart, domain layer never knows where data comes from.
class Offer {
  final String id;
  final String listingId;
  final String buyerId;
  final String farmerId;
  final String cropType;
  final double pricePerKg;
  final int quantityKg;
  final String status; // pending, accepted, rejected
  final DateTime createdAt;

  const Offer({
    required this.id,
    required this.listingId,
    required this.buyerId,
    required this.farmerId,
    required this.cropType,
    required this.pricePerKg,
    required this.quantityKg,
    required this.status,
    required this.createdAt,
  });

  bool get isPending => status == 'pending';
}
