import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/listing.dart';
import '../../domain/entities/listing_status.dart';

/// Firestore field names match the team ERD exactly.
class ListingModel {
  const ListingModel({
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

  static const collectionName = 'listings';

  factory ListingModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ListingModel(
      id: doc.id,
      sellerId: data['sellerId'] as String,
      cropType: data['cropType'] as String,
      pricePerKg: (data['pricePerKg'] as num).toDouble(),
      quantityKg: (data['quantityKg'] as num).toDouble(),
      availableFrom: (data['availableFrom'] as Timestamp).toDate(),
      location: data['location'] as String,
      photoUrl: data['photoUrl'] as String,
      status: ListingStatus.fromFirestore(data['status'] as String),
      offerCount: data['offerCount'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore({DateTime? updatedAtOverride}) {
    return {
      'sellerId': sellerId,
      'cropType': cropType,
      'pricePerKg': pricePerKg,
      'quantityKg': quantityKg,
      'availableFrom': Timestamp.fromDate(availableFrom),
      'location': location,
      'photoUrl': photoUrl,
      'status': status.firestoreValue,
      'offerCount': offerCount,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAtOverride != null)
        'updatedAt': Timestamp.fromDate(updatedAtOverride),
    };
  }

  Listing toEntity() {
    return Listing(
      id: id,
      sellerId: sellerId,
      cropType: cropType,
      pricePerKg: pricePerKg,
      quantityKg: quantityKg,
      availableFrom: availableFrom,
      location: location,
      photoUrl: photoUrl,
      status: status,
      offerCount: offerCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
