import 'package:cloud_firestore/cloud_firestore.dart';

import '../../listings/data/listing_model.dart';
import '../domain/offer.dart';
import '../domain/offer_repository.dart';

/// Talks to Firestore. This is the only file in the offers feature
/// that imports cloud_firestore.
class OfferRepositoryImpl implements OfferRepository {
  OfferRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _offersRef =>
      _firestore.collection('offers');

  Offer _offerFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return Offer(
      id: doc.id,
      listingId: data['listingId'] as String,
      buyerId: data['buyerId'] as String,
      farmerId: data['farmerId'] as String,
      cropType: data['cropType'] as String? ?? 'Produce',
      pricePerKg: (data['pricePerKg'] as num).toDouble(),
      quantityKg: (data['quantityKg'] as num).toInt(),
      status: data['status'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  List<Offer> _sortedOffers(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final offers = snapshot.docs.map(_offerFromDoc).toList();
    offers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return offers;
  }

  @override
  Future<void> submitOffer(Offer offer) async {
    final batch = _firestore.batch();
    final offerRef = _offersRef.doc(offer.id);
    batch.set(offerRef, {
      'listingId': offer.listingId,
      'buyerId': offer.buyerId,
      'farmerId': offer.farmerId,
      'cropType': offer.cropType,
      'pricePerKg': offer.pricePerKg,
      'quantityKg': offer.quantityKg,
      'status': offer.status,
      'createdAt': Timestamp.fromDate(offer.createdAt),
    });

    final listingRef = _firestore
        .collection(ListingModel.collectionName)
        .doc(offer.listingId);
    batch.update(listingRef, {
      'offerCount': FieldValue.increment(1),
      'status': 'with_offers',
    });

    await batch.commit();
  }

  @override
  Stream<List<Offer>> watchOffersForListing(String listingId) {
    return _offersRef
        .where('listingId', isEqualTo: listingId)
        .snapshots()
        .map(_sortedOffers);
  }

  @override
  Stream<List<Offer>> watchOffersForFarmer(String farmerId) {
    return _offersRef
        .where('farmerId', isEqualTo: farmerId)
        .snapshots()
        .map(_sortedOffers);
  }

  @override
  Future<void> updateOfferStatus({
    required String offerId,
    required String status,
  }) async {
    await _offersRef.doc(offerId).update({'status': status});
  }
}
