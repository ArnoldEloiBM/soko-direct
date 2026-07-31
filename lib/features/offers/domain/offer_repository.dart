import 'offer.dart';

///The rules for offer data. No Firebase import here on purpose --
///the domain layer never knows where data comes from.
abstract class OfferRepository {
  Future<void> submitOffer(Offer offer);
  Stream<List<Offer>> watchOffersForListing(String listingId);
  Stream<List<Offer>> watchOffersForFarmer(String farmerId);
  Future<void> updateOfferStatus({
    required String offerId,
    required String status,
  });
}
