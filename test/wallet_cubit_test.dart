import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soko_direct/features/wallet/domain/wallet_model.dart';
import 'package:soko_direct/features/wallet/domain/wallet_repository.dart';
import 'package:soko_direct/features/wallet/presentation/wallet_cubit.dart';
import 'package:soko_direct/features/wallet/presentation/wallet_state.dart';

// A tiny fake repository just for this test — separate from
// FakeWalletRepository in lib/, so the test controls exactly what happens.
class _TestWalletRepository implements WalletRepository {
  bool shouldFail = false;

  @override
  Future<WalletModel> getWallet(String userId) async {
    if (shouldFail) throw Exception('Network error');
    return const WalletModel(
      userId: 'demo-user',
      balance: 5000,
      provider: 'MTN',
    );
  }

  @override
  Future<void> updateBalance(String userId, double newBalance) async {
    if (shouldFail) throw Exception('Network error');
  }
}

void main() {
  group('WalletCubit', () {
    late _TestWalletRepository repository;

    setUp(() {
      repository = _TestWalletRepository();
    });

    blocTest<WalletCubit, WalletState>(
      'emits [WalletLoading, WalletLoaded] when loadWallet succeeds',
      build: () => WalletCubit(repository),
      act: (cubit) => cubit.loadWallet('demo-user'),
      expect: () => [
        isA<WalletLoading>(),
        isA<WalletLoaded>()
            .having((s) => s.wallet.balance, 'balance', 5000)
            .having((s) => s.wallet.provider, 'provider', 'MTN'),
      ],
    );

    blocTest<WalletCubit, WalletState>(
      'emits [WalletLoading, WalletError] when loadWallet fails',
      build: () {
        repository.shouldFail = true;
        return WalletCubit(repository);
      },
      act: (cubit) => cubit.loadWallet('demo-user'),
      expect: () => [isA<WalletLoading>(), isA<WalletError>()],
    );

    blocTest<WalletCubit, WalletState>(
      'topUp increases the balance by the given amount',
      build: () => WalletCubit(repository),
      act: (cubit) async {
        await cubit.loadWallet('demo-user'); // must load first
        await cubit.topUp('demo-user', 1000);
      },
      expect: () => [
        isA<WalletLoading>(),
        isA<WalletLoaded>().having((s) => s.wallet.balance, 'balance', 5000),
        isA<WalletLoaded>().having((s) => s.wallet.balance, 'balance', 6000),
      ],
    );
  });
}
