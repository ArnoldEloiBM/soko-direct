import 'package:equatable/equatable.dart';

import 'listing_status.dart';

/// Domain entity for a produce listing (matches Firestore ERD).
class Listing extends Equatable {
  const Listing({
    required this.id,
    required this.sellerId,
    required this.cropType,
    required this.pricePerKg,
    required this.quantityKg,
    required this.availableFrom,
    required this.location,
    required this.photoUrl,
    required this.status,
    required this.offerCount,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String sellerId;
  final String cropType;
  final double pricePerKg;
  final double quantityKg;
  final DateTime availableFrom;
  final String location;
  final String photoUrl;
  final ListingStatus status;
  final int offerCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Listing copyWith({
    String? id,
    String? sellerId,
    String? cropType,
    double? pricePerKg,
    double? quantityKg,
    DateTime? availableFrom,
    String? location,
    String? photoUrl,
    ListingStatus? status,
    int? offerCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Listing(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      cropType: cropType ?? this.cropType,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      quantityKg: quantityKg ?? this.quantityKg,
      availableFrom: availableFrom ?? this.availableFrom,
      location: location ?? this.location,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      offerCount: offerCount ?? this.offerCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    sellerId,
    cropType,
    pricePerKg,
    quantityKg,
    availableFrom,
    location,
    photoUrl,
    status,
    offerCount,
    createdAt,
    updatedAt,
  ];
}
