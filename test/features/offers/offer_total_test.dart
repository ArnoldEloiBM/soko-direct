import 'package:flutter_test/flutter_test.dart';
import 'package:soko_direct/features/offers/domain/offer_total.dart';

void main() {
  group('calculateOfferTotal', () {
    test('multiplies price per kg by quantity correctly', () {
    
      final total = calculateOfferTotal(500, 8);
      expect(total, 4000);
    });

    test('returns 0 when quantity is 0', () {
      final total = calculateOfferTotal(480, 0);
      expect(total, 0);
    });

    test('handles decimal prices correctly', () {
      final total = calculateOfferTotal(350.5, 10);
      expect(total, 3505);
    });
  });
}