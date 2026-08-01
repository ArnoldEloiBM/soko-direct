import '../domain/market_price_model.dart';
import '../domain/market_repository.dart';

class FakeMarketRepository implements MarketRepository {
  @override
  Stream<List<MarketPrice>> watchMarketPrices() async* {
    await Future.delayed(const Duration(milliseconds: 600)); // fake network
    yield const [
      MarketPrice(
        cropType: 'Maize',
        averagePrice: 450,
        minPrice: 400,
        maxPrice: 520,
        listingCount: 8,
      ),
      MarketPrice(
        cropType: 'Beans',
        averagePrice: 900,
        minPrice: 850,
        maxPrice: 1000,
        listingCount: 5,
      ),
      MarketPrice(
        cropType: 'Irish Potatoes',
        averagePrice: 380,
        minPrice: 350,
        maxPrice: 420,
        listingCount: 12,
      ),
      MarketPrice(
        cropType: 'Tomatoes',
        averagePrice: 700,
        minPrice: 600,
        maxPrice: 800,
        listingCount: 4,
      ),
    ];
  }
}
