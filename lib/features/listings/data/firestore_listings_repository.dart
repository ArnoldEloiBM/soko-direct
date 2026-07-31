import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../domain/listing.dart';
import '../domain/listing_input.dart';
import '../domain/listing_status.dart';
import '../domain/listings_repository.dart';
import 'listing_model.dart';

class FirestoreListingsRepository implements ListingsRepository {
  FirestoreListingsRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  String _newListingId() {
    return _firestore.collection(ListingModel.collectionName).doc().id;
  }

  @override
  Stream<List<Listing>> watchUserListings(String sellerId) {
    return _firestore
        .collection(ListingModel.collectionName)
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(ListingModel.fromFirestore)
              .map((model) => model.toEntity())
              .toList(),
        );
  }

  @override
  Future<Listing> createListing({
    required String sellerId,
    required ListingInput input,
  }) async {
    final listingId = _newListingId();
    final photoUrl = await _uploadPhoto(
      sellerId: sellerId,
      listingId: listingId,
      localPath: input.photoPath!,
    );

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
    var photoUrl = input.existingPhotoUrl ?? '';

    if (input.photoPath != null && input.photoPath!.isNotEmpty) {
      await _deletePhoto(sellerId: sellerId, listingId: listingId);
      photoUrl = await _uploadPhoto(
        sellerId: sellerId,
        listingId: listingId,
        localPath: input.photoPath!,
      );
    }

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

    await _deletePhoto(sellerId: sellerId, listingId: listingId);
    await docRef.delete();
  }

  Future<String> _uploadPhoto({
    required String sellerId,
    required String listingId,
    required String localPath,
  }) async {
    final file = File(localPath);
    final ref = _storage.ref().child('listings/$sellerId/$listingId.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<void> _deletePhoto({
    required String sellerId,
    required String listingId,
  }) async {
    final ref = _storage.ref().child('listings/$sellerId/$listingId.jpg');
    try {
      await ref.delete();
    } on FirebaseException catch (error) {
      if (error.code != 'object-not-found') {
        rethrow;
      }
    }
  }
}
