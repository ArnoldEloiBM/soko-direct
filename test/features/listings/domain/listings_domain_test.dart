import 'package:flutter_test/flutter_test.dart';
import 'package:soko_direct/features/listings/domain/listing.dart';
import 'package:soko_direct/features/listings/domain/listing_input.dart';
import 'package:soko_direct/features/listings/domain/listing_status.dart';
import 'package:soko_direct/features/listings/domain/listings_domain.dart';

import '../../../helpers/fake_listings_repository.dart';

void main() {
  late FakeListingsRepository repository;
  late ListingsDomain domain;

  setUp(() {
    repository = FakeListingsRepository();
    domain = ListingsDomain(repository: repository);
  });

  tearDown(() {
    repository.dispose();
  });

  group('ListingsDomain', () {
    test('rejects create when price is zero', () async {
      final input = ListingInput(
        cropType: 'Tomatoes',
        pricePerKg: 0,
        quantityKg: 50,
        availableFrom: DateTime.now().add(const Duration(days: 1)),
        location: 'Musanze',
        photoPath: '/tmp/photo.jpg',
      );

      expect(
        () => domain.createListing(sellerId: 'user-1', input: input),
        throwsA(isA<ListingsDomainException>()),
      );
    });

    test('creates listing when input is valid', () async {
      final input = ListingInput(
        cropType: 'Tomatoes',
        pricePerKg: 480,
        quantityKg: 50,
        availableFrom: DateTime.now().add(const Duration(days: 1)),
        location: 'Musanze',
        photoPath: '/tmp/photo.jpg',
      );

      final listing = await domain.createListing(
        sellerId: 'user-1',
        input: input,
      );

      expect(listing.cropType, 'Tomatoes');
      expect(listing.pricePerKg, 480);
      expect(listing.sellerId, 'user-1');
    });

    test('rejects create when quantity is zero', () async {
      final input = ListingInput(
        cropType: 'Tomatoes',
        pricePerKg: 480,
        quantityKg: 0,
        availableFrom: DateTime.now().add(const Duration(days: 1)),
        location: 'Musanze',
        photoPath: '/tmp/photo.jpg',
      );

      expect(
        () => domain.createListing(sellerId: 'user-1', input: input),
        throwsA(isA<ListingsDomainException>()),
      );
    });

    test('marks listing sold when quantity updated to zero', () async {
      final createInput = ListingInput(
        cropType: 'Tomatoes',
        pricePerKg: 480,
        quantityKg: 50,
        availableFrom: DateTime.now().add(const Duration(days: 1)),
        location: 'Musanze',
        photoPath: '/tmp/photo.jpg',
      );

      final created = await domain.createListing(
        sellerId: 'user-1',
        input: createInput,
      );

      final updateInput = ListingInput(
        cropType: 'Tomatoes',
        pricePerKg: 480,
        quantityKg: 0,
        availableFrom: created.availableFrom,
        location: 'Musanze',
        existingPhotoUrl: created.photoUrl,
      );

      final updated = await domain.updateListing(
        listingId: created.id,
        sellerId: 'user-1',
        input: updateInput,
      );

      expect(updated.status, ListingStatus.sold);
      expect(updated.isSoldOut, isTrue);
    });

    test('rejects update when listing is already sold', () async {
      repository = FakeListingsRepository(
        seed: [
          Listing(
            id: 'sold-1',
            sellerId: 'user-1',
            cropType: 'Onions',
            pricePerKg: 320,
            quantityKg: 0,
            availableFrom: DateTime.now(),
            location: 'Musanze',
            photoUrl: '',
            status: ListingStatus.sold,
            offerCount: 0,
            createdAt: DateTime.now(),
          ),
        ],
      );
      domain = ListingsDomain(repository: repository);

      final input = ListingInput(
        cropType: 'Onions',
        pricePerKg: 320,
        quantityKg: 10,
        availableFrom: DateTime.now().add(const Duration(days: 1)),
        location: 'Musanze',
        existingPhotoUrl: '',
      );

      expect(
        () => domain.updateListing(
          listingId: 'sold-1',
          sellerId: 'user-1',
          input: input,
        ),
        throwsA(isA<ListingsDomainException>()),
      );
    });
  });
}
