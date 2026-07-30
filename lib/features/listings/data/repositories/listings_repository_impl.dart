import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/listing.dart';
import '../../domain/entities/listing_input.dart';
import '../../domain/repositories/listings_repository.dart';
import '../datasources/listings_remote_datasource.dart';

class ListingsRepositoryImpl implements ListingsRepository {
  ListingsRepositoryImpl({
    ListingsFirestoreDataSource? firestoreDataSource,
    ListingsStorageDataSource? storageDataSource,
  }) : _firestore = firestoreDataSource ?? ListingsFirestoreDataSource(),
       _storage = storageDataSource ?? ListingsStorageDataSource();

  final ListingsFirestoreDataSource _firestore;
  final ListingsStorageDataSource _storage;

  @override
  Stream<List<Listing>> watchUserListings(String sellerId) {
    return _firestore.watchUserListings(sellerId);
  }

  @override
  Future<Listing> createListing({
    required String sellerId,
    required ListingInput input,
  }) async {
    final docRef = FirebaseFirestore.instance.collection('listings').doc();
    final listingId = docRef.id;

    final photoUrl = await _storage.uploadPhoto(
      sellerId: sellerId,
      listingId: listingId,
      localPath: input.photoPath!,
    );

    return _firestore.createListing(
      listingId: listingId,
      sellerId: sellerId,
      input: input,
      photoUrl: photoUrl,
    );
  }

  @override
  Future<Listing> updateListing({
    required String listingId,
    required String sellerId,
    required ListingInput input,
  }) async {
    var photoUrl = input.existingPhotoUrl ?? '';

    if (input.photoPath != null && input.photoPath!.isNotEmpty) {
      await _storage.deletePhoto(sellerId: sellerId, listingId: listingId);
      photoUrl = await _storage.uploadPhoto(
        sellerId: sellerId,
        listingId: listingId,
        localPath: input.photoPath!,
      );
    }

    return _firestore.updateListing(
      listingId: listingId,
      sellerId: sellerId,
      input: input,
      photoUrl: photoUrl,
    );
  }

  @override
  Future<void> deleteListing({
    required String listingId,
    required String sellerId,
  }) async {
    await _storage.deletePhoto(sellerId: sellerId, listingId: listingId);
    await _firestore.deleteListing(listingId: listingId, sellerId: sellerId);
  }
}
