import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soko_direct/features/listings/domain/listing.dart';
import 'package:soko_direct/features/listings/domain/listing_status.dart';
import 'package:soko_direct/features/listings/presentation/listing_card.dart';

void main() {
  testWidgets('ListingCard shows crop details and Active badge', (
    WidgetTester tester,
  ) async {
    final listing = Listing(
      id: '1',
      sellerId: 'test-user',
      cropType: 'Tomatoes',
      pricePerKg: 480,
      quantityKg: 50,
      availableFrom: DateTime(2026, 8, 1),
      location: 'Musanze',
      photoUrl: '',
      status: ListingStatus.active,
      offerCount: 0,
      createdAt: DateTime(2026, 7, 30, 10),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListingCard(listing: listing),
        ),
      ),
    );

    expect(find.text('Tomatoes'), findsOneWidget);
    expect(find.textContaining('50 kg'), findsOneWidget);
    expect(find.textContaining('480 RWF/kg'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
  });

  testWidgets('ListingCard shows Sold badge for sold listing', (
    WidgetTester tester,
  ) async {
    final listing = Listing(
      id: '2',
      sellerId: 'test-user',
      cropType: 'Onions',
      pricePerKg: 320,
      quantityKg: 30,
      availableFrom: DateTime(2026, 8, 1),
      location: 'Musanze',
      photoUrl: '',
      status: ListingStatus.sold,
      offerCount: 0,
      createdAt: DateTime(2026, 7, 27, 10),
      updatedAt: DateTime(2026, 7, 28, 10),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListingCard(listing: listing),
        ),
      ),
    );

    expect(find.text('Sold'), findsOneWidget);
    expect(find.text('Active'), findsNothing);
    expect(find.textContaining('30 kg'), findsOneWidget);
  });
}
