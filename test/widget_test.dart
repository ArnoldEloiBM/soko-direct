import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soko_direct/app.dart';
import 'package:soko_direct/core/theme/theme_cubit.dart';
import 'package:soko_direct/features/wallet/data/fake_wallet_repository.dart';
import 'package:soko_direct/features/wallet/presentation/wallet_cubit.dart';

void main() {
  testWidgets('App loads and shows the Wallet screen', (tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(create: (_) => WalletCubit(FakeWalletRepository())),
        ],
        child: const SokoDirectApp(),
      ),
    );

    // Let the async loadWallet() call inside WalletScreen finish.
    await tester.pumpAndSettle();

    expect(find.text('Wallet'), findsOneWidget);
    expect(find.textContaining('RWF'), findsWidgets); // allow multiple RWF texts
    expect(find.text('Provider: MTN'), findsOneWidget); // unique, specific check
  });
}