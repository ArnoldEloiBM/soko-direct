import 'listing.dart';
import 'listing_input.dart';
import 'listing_options.dart';
import 'listings_repository.dart';

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
    _validateInputForCreate(input, requirePhoto: true);
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
    _validateInputForUpdate(input, requirePhoto: input.existingPhotoUrl == null);
    try {
      return await _repository.updateListing(
        listingId: listingId,
        sellerId: sellerId,
        input: input,
      );
    } on StateError catch (error) {
      if (error.message == 'Listing already sold') {
        throw const ListingsDomainException(
          'This listing is already sold and cannot be edited.',
        );
      }
      rethrow;
    }
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

  void _validateInputForCreate(ListingInput input, {required bool requirePhoto}) {
    _validateSharedFields(input, requirePhoto: requirePhoto);
    if (input.quantityKg <= 0) {
      throw const ListingsDomainException(
        'Quantity must be greater than zero.',
      );
    }
    _validateAvailableDate(input.availableFrom);
  }

  void _validateInputForUpdate(ListingInput input, {required bool requirePhoto}) {
    _validateSharedFields(input, requirePhoto: requirePhoto);
    if (input.quantityKg < 0) {
      throw const ListingsDomainException('Quantity cannot be negative.');
    }
    // Setting quantity to 0 marks the listing sold (stock empty).
    if (input.quantityKg > 0) {
      _validateAvailableDate(input.availableFrom);
    }
  }

  void _validateSharedFields(ListingInput input, {required bool requirePhoto}) {
    if (!ListingOptions.cropTypes.contains(input.cropType)) {
      throw const ListingsDomainException('Please select a valid crop type.');
    }
    if (input.pricePerKg <= 0) {
      throw const ListingsDomainException('Price must be greater than zero.');
    }
    if (!ListingOptions.locations.contains(input.location)) {
      throw const ListingsDomainException('Please select a valid location.');
    }
    if (requirePhoto && (input.photoPath == null || input.photoPath!.isEmpty)) {
      throw const ListingsDomainException(
        'Please add a photo of your produce.',
      );
    }
  }

  void _validateAvailableDate(DateTime availableFrom) {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    if (availableFrom.isBefore(startOfToday)) {
      throw const ListingsDomainException(
        'Available date cannot be in the past.',
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
