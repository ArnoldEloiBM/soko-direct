import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../domain/entities/listing.dart';
import '../../domain/entities/listing_input.dart';
import '../../domain/entities/listing_status.dart';
import '../models/listing_model.dart';

/// Talks to Firestore only — no UI or validation logic here.
class ListingsFirestoreDataSource {
  ListingsFirestoreDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

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

  Future<Listing> createListing({
    required String listingId,
    required String sellerId,
    required ListingInput input,
    required String photoUrl,
  }) async {
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

  Future<Listing> updateListing({
    required String listingId,
    required String sellerId,
    required ListingInput input,
    required String photoUrl,
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

    final now = DateTime.now();
    final updated = ListingModel(
      id: listingId,
      sellerId: sellerId,
      cropType: input.cropType,
      pricePerKg: input.pricePerKg,
      quantityKg: input.quantityKg,
      availableFrom: input.availableFrom,
      location: input.location,
      photoUrl: photoUrl,
      status: existing.status,
      offerCount: existing.offerCount,
      createdAt: existing.createdAt,
      updatedAt: now,
    );

    await docRef.update(updated.toFirestore(updatedAtOverride: now));
    return updated.toEntity();
  }

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

/// Talks to Firebase Storage only.
class ListingsStorageDataSource {
  ListingsStorageDataSource({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> uploadPhoto({
    required String sellerId,
    required String listingId,
    required String localPath,
  }) async {
    final file = File(localPath);
    final ref = _storage.ref().child('listings/$sellerId/$listingId.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<void> deletePhoto({
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
