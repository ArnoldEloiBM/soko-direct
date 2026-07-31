import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/market_price_model.dart';
import '../domain/market_repository.dart';
class FirestoreMarketRepository implements MarketRepository {
  final FirebaseFirestore _firestore;

  FirestoreMarketRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<MarketPrice>> watchMarketPrices() {
    return _firestore
        .collection('listings')
        // Both 'active' and 'with_offers' are still on the market;
        // only 'sold' listings are excluded from price stats.
        .where('status', whereIn: ['active', 'with_offers'])
        .snapshots()
        .map(_aggregateByCrop);
  }

  List<MarketPrice> _aggregateByCrop(QuerySnapshot<Map<String, dynamic>> snap) {
    final Map<String, List<double>> pricesByCrop = {};

    for (final doc in snap.docs) {
      final data = doc.data();
      final crop = data['cropType'] as String?;
      final price = (data['pricePerKg'] as num?)?.toDouble();
      if (crop == null || price == null) continue; // skip malformed docs
      pricesByCrop.putIfAbsent(crop, () => []).add(price);
    }

    final result = pricesByCrop.entries.map((entry) {
      final prices = entry.value;
      final sum = prices.reduce((a, b) => a + b);
      return MarketPrice(
        cropType: entry.key,
        averagePrice: sum / prices.length,
        minPrice: prices.reduce((a, b) => a < b ? a : b),
        maxPrice: prices.reduce((a, b) => a > b ? a : b),
        listingCount: prices.length,
      );
    }).toList()
      ..sort((a, b) => a.cropType.compareTo(b.cropType));

    return result;
  }
}
