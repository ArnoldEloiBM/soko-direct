import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/listing.dart';
import '../domain/listing_input.dart';
import '../domain/listing_options.dart';
import '../domain/listing_status.dart';
import '../domain/listings_repository.dart';
import 'listing_model.dart';

class FirestoreListingsRepository implements ListingsRepository {
  FirestoreListingsRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  String _newListingId() {
    return _firestore.collection(ListingModel.collectionName).doc().id;
  }

  String _resolvePhotoUrl(ListingInput input) {
    if (input.photoPath != null && input.photoPath!.isNotEmpty) {
      return input.photoPath!;
    }
    if (input.existingPhotoUrl != null && input.existingPhotoUrl!.isNotEmpty) {
      return input.existingPhotoUrl!;
    }
    return ListingOptions.photoAssetFor(input.cropType);
  }

  List<Listing> _sortedListings(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final listings = snapshot.docs
        .map(ListingModel.fromFirestore)
        .map((model) => model.toEntity())
        .toList();
    listings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return listings;
  }

  @override
  Stream<List<Listing>> watchUserListings(String sellerId) {
    // Sort client-side to avoid requiring a composite Firestore index.
    return _firestore
        .collection(ListingModel.collectionName)
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map(_sortedListings);
  }

  @override
  Stream<List<Listing>> watchAllListings() {
    return _firestore
        .collection(ListingModel.collectionName)
        .snapshots()
        .map(_sortedListings);
  }

  @override
  Future<Listing> createListing({
    required String sellerId,
    required ListingInput input,
  }) async {
    final listingId = _newListingId();
    final photoUrl = _resolvePhotoUrl(input);

    final now = DateTime.now();
    final docRef = _firestore
        .collection(ListingModel.collectionName)
        .doc(listingId);

    final model = ListingModel(
      id: docRef.id,
      sellerId: sellerId,
      cropType: input.cropType,
      pricePerKg: input.pricePerKg,
      quantityKg: input.quantityKg,
      availableFrom: input.availableFrom,
      location: input.location,
      photoUrl: photoUrl,
      status: ListingStatus.active,
      offerCount: 0,
      createdAt: now,
    );

    await docRef.set(model.toFirestore());
    return model.toEntity();
  }

  @override
  Future<Listing> updateListing({
    required String listingId,
    required String sellerId,
    required ListingInput input,
  }) async {
    final photoUrl = _resolvePhotoUrl(input);

    final docRef = _firestore
        .collection(ListingModel.collectionName)
        .doc(listingId);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      throw StateError('Listing not found');
    }

    final existing = ListingModel.fromFirestore(snapshot);
    if (existing.sellerId != sellerId) {
      throw StateError('Permission denied');
    }
    if (existing.status == ListingStatus.sold) {
      throw StateError('Listing already sold');
    }

    final now = DateTime.now();
    final resolvedStatus = input.quantityKg <= 0
        ? ListingStatus.sold
        : existing.status;
    final updated = ListingModel(
      id: listingId,
      sellerId: sellerId,
      cropType: input.cropType,
      pricePerKg: input.pricePerKg,
      quantityKg: input.quantityKg,
      availableFrom: input.availableFrom,
      location: input.location,
      photoUrl: photoUrl,
      status: resolvedStatus,
      offerCount: existing.offerCount,
      createdAt: existing.createdAt,
      updatedAt: now,
    );

    await docRef.update(updated.toFirestore(updatedAtOverride: now));
    return updated.toEntity();
  }

  @override
  Future<void> deleteListing({
    required String listingId,
    required String sellerId,
  }) async {
    final docRef = _firestore
        .collection(ListingModel.collectionName)
        .doc(listingId);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      throw StateError('Listing not found');
    }

    final existing = ListingModel.fromFirestore(snapshot);
    if (existing.sellerId != sellerId) {
      throw StateError('Permission denied');
    }

    await docRef.delete();
  }
}
