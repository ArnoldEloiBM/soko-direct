import 'listing.dart';
import 'listing_input.dart';

/// Data-layer contract. Screens and Cubits never implement this directly.
abstract class ListingsRepository {
  Stream<List<Listing>> watchUserListings(String sellerId);

  Stream<List<Listing>> watchAllListings();

  Future<Listing> createListing({
    required String sellerId,
    required ListingInput input,
  });

  Future<Listing> updateListing({
    required String listingId,
    required String sellerId,
    required ListingInput input,
  });

  Future<void> deleteListing({
    required String listingId,
    required String sellerId,
  });
}
