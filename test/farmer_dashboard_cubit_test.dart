import 'package:flutter_test/flutter_test.dart';
import 'package:soko_direct/features/dashboard/data/fake_market_repository.dart';
import 'package:soko_direct/features/dashboard/domain/market_price_model.dart';
import 'package:soko_direct/features/dashboard/domain/market_repository.dart';
import 'package:soko_direct/features/dashboard/presentation/farmer_dashboard_cubit.dart';
import 'package:soko_direct/features/dashboard/presentation/farmer_dashboard_state.dart';

class BrokenMarketRepository implements MarketRepository {
  @override
  Stream<List<MarketPrice>> watchMarketPrices() =>
      Stream.error(Exception('network down'));
}

void main() {
  group('FarmerDashboardCubit', () {
    test('emits Loading then Loaded with prices from the repository', () async {
      final cubit = FarmerDashboardCubit(FakeMarketRepository());

      final states = <FarmerDashboardState>[];
      final sub = cubit.stream.listen(states.add);

      cubit.watchPrices();
      await Future<void>.delayed(const Duration(milliseconds: 800));

      expect(states.first, isA<FarmerDashboardLoading>());
      expect(states.last, isA<FarmerDashboardLoaded>());
      final loaded = states.last as FarmerDashboardLoaded;
      expect(loaded.prices, isNotEmpty);

      await sub.cancel();
      await cubit.close();
    });

    test('emits Error when the repository stream fails', () async {
      final cubit = FarmerDashboardCubit(BrokenMarketRepository());

      cubit.watchPrices();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(cubit.state, isA<FarmerDashboardError>());
      await cubit.close();
    });
  });
}
