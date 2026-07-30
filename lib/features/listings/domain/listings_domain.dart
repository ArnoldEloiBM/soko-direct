import 'constants/listing_options.dart';
import 'entities/listing.dart';
import 'entities/listing_input.dart';
import 'repositories/listings_repository.dart';

/// Domain rules: validation and orchestration. Cubits call this, not Firebase.
class ListingsDomain {
  ListingsDomain({required ListingsRepository repository})
    : _repository = repository;

  final ListingsRepository _repository;

  Stream<List<Listing>> watchUserListings(String sellerId) {
    if (sellerId.isEmpty) {
      throw const ListingsDomainException(
        'You must be signed in to view listings.',
      );
    }
    return _repository.watchUserListings(sellerId);
  }

  Future<Listing> createListing({
    required String sellerId,
    required ListingInput input,
  }) async {
    _validateSellerId(sellerId);
    _validateInput(input, requirePhoto: true);
    return _repository.createListing(sellerId: sellerId, input: input);
  }

  Future<Listing> updateListing({
    required String listingId,
    required String sellerId,
    required ListingInput input,
  }) async {
    _validateSellerId(sellerId);
    if (listingId.isEmpty) {
      throw const ListingsDomainException('Listing id is required.');
    }
    _validateInput(input, requirePhoto: input.existingPhotoUrl == null);
    return _repository.updateListing(
      listingId: listingId,
      sellerId: sellerId,
      input: input,
    );
  }

  Future<void> deleteListing({
    required String listingId,
    required String sellerId,
  }) async {
    _validateSellerId(sellerId);
    if (listingId.isEmpty) {
      throw const ListingsDomainException('Listing id is required.');
    }
    await _repository.deleteListing(listingId: listingId, sellerId: sellerId);
  }

  void _validateSellerId(String sellerId) {
    if (sellerId.isEmpty) {
      throw const ListingsDomainException(
        'You must be signed in to manage listings.',
      );
    }
  }

  void _validateInput(ListingInput input, {required bool requirePhoto}) {
    if (!ListingOptions.cropTypes.contains(input.cropType)) {
      throw const ListingsDomainException('Please select a valid crop type.');
    }
    if (input.pricePerKg <= 0) {
      throw const ListingsDomainException('Price must be greater than zero.');
    }
    if (input.quantityKg <= 0) {
      throw const ListingsDomainException(
        'Quantity must be greater than zero.',
      );
    }
    if (!ListingOptions.locations.contains(input.location)) {
      throw const ListingsDomainException('Please select a valid location.');
    }
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    if (input.availableFrom.isBefore(startOfToday)) {
      throw const ListingsDomainException(
        'Available date cannot be in the past.',
      );
    }
    if (requirePhoto && (input.photoPath == null || input.photoPath!.isEmpty)) {
      throw const ListingsDomainException(
        'Please add a photo of your produce.',
      );
    }
  }
}

class ListingsDomainException implements Exception {
  const ListingsDomainException(this.message);

  final String message;

  @override
  String toString() => message;
}
