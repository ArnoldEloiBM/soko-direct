import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/offer.dart';
import '../domain/offer_repository.dart';

///Talks to Firestore. This is the only file in the offers feature
///that imports cloud_firestore.
class OfferRepositoryImpl implements OfferRepository {
  final FirebaseFirestore _firestore;

  OfferRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _offersRef =>
      _firestore.collection('offers');

  @override
  Future<void> submitOffer(Offer offer) async {
    await _offersRef.doc(offer.id).set({
      'listingId': offer.listingId,
      'buyerId': offer.buyerId,
      'farmerId': offer.farmerId,
      'pricePerKg': offer.pricePerKg,
      'quantityKg': offer.quantityKg,
      'status': offer.status,
      'createdAt': Timestamp.fromDate(offer.createdAt),
    });
  }

  @override
  Stream<List<Offer>> watchOffersForListing(String listingId) {
    return _offersRef
        .where('listingId', isEqualTo: listingId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return Offer(
                id: doc.id,
                listingId: data['listingId'] as String,
                buyerId: data['buyerId'] as String,
                farmerId: data['farmerId'] as String,
                pricePerKg: (data['pricePerKg'] as num).toDouble(),
                quantityKg: data['quantityKg'] as int,
                status: data['status'] as String,
                createdAt: (data['createdAt'] as Timestamp).toDate(),
              );
            }).toList());
  }
}