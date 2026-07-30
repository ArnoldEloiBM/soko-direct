import '../entities/listing.dart';
import '../entities/listing_input.dart';

/// Data-layer contract. Screens and Cubits never implement this directly.
abstract class ListingsRepository {
  Stream<List<Listing>> watchUserListings(String sellerId);

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
