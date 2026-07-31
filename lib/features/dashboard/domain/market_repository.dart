import 'market_price_model.dart';

/// The dashboard Cubit only talks to this contract. A Stream (not a Future)
/// "UI updates after a change with no manual refresh".
abstract class MarketRepository {
  Stream<List<MarketPrice>> watchMarketPrices();
}
