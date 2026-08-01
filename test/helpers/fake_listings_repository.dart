import 'dart:async';

import 'package:soko_direct/features/listings/domain/listing.dart';
import 'package:soko_direct/features/listings/domain/listing_input.dart';
import 'package:soko_direct/features/listings/domain/listing_options.dart';
import 'package:soko_direct/features/listings/domain/listing_status.dart';
import 'package:soko_direct/features/listings/domain/listings_repository.dart';

class FakeListingsRepository implements ListingsRepository {
  FakeListingsRepository({List<Listing>? seed})
    : _listings = List.of(seed ?? []);

  final List<Listing> _listings;
  final StreamController<List<Listing>> _controller =
      StreamController<List<Listing>>.broadcast();

  @override
  Stream<List<Listing>> watchUserListings(String sellerId) async* {
    yield _filtered(sellerId);
    await for (final _ in _controller.stream) {
      yield _filtered(sellerId);
    }
  }

  @override
  Stream<List<Listing>> watchAllListings() async* {
    yield List.unmodifiable(_listings);
    await for (final _ in _controller.stream) {
      yield List.unmodifiable(_listings);
    }
  }

  List<Listing> _filtered(String sellerId) {
    return _listings.where((item) => item.sellerId == sellerId).toList();
  }

  @override
  Future<Listing> createListing({
    required String sellerId,
    required ListingInput input,
  }) async {
    final listing = Listing(
      id: 'listing-${_listings.length + 1}',
      sellerId: sellerId,
      cropType: input.cropType,
      pricePerKg: input.pricePerKg,
      quantityKg: input.quantityKg,
      availableFrom: input.availableFrom,
      location: input.location,
      photoUrl:
          input.photoPath ??
          input.existingPhotoUrl ??
          ListingOptions.photoAssetFor(input.cropType),
      status: ListingStatus.active,
      offerCount: 0,
      createdAt: DateTime.now(),
    );
    _listings.insert(0, listing);
    _emit();
    return listing;
  }

  @override
  Future<Listing> updateListing({
    required String listingId,
    required String sellerId,
    required ListingInput input,
  }) async {
    final index = _listings.indexWhere((item) => item.id == listingId);
    if (index == -1) {
      throw StateError('Listing not found');
    }
    final existing = _listings[index];
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
    final updated = existing.copyWith(
      cropType: input.cropType,
      pricePerKg: input.pricePerKg,
      quantityKg: input.quantityKg,
      availableFrom: input.availableFrom,
      location: input.location,
      photoUrl: input.photoPath ?? input.existingPhotoUrl ?? existing.photoUrl,
      status: resolvedStatus,
      updatedAt: now,
    );
    _listings[index] = updated;
    _emit();
    return updated;
  }

  @override
  Future<void> deleteListing({
    required String listingId,
    required String sellerId,
  }) async {
    _listings.removeWhere((item) => item.id == listingId);
    _emit();
  }

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_listings));
    }
  }

  void dispose() {
    _controller.close();
  }
}
