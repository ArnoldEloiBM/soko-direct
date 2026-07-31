import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soko_direct/app.dart';
import 'package:soko_direct/core/theme/theme_cubit.dart';
import 'package:soko_direct/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:soko_direct/features/wallet/data/fake_wallet_repository.dart';
import 'package:soko_direct/features/wallet/presentation/wallet_cubit.dart';
import 'package:soko_direct/features/wallet/presentation/wallet_screen.dart';

import 'helpers/fake_auth_repository.dart';

Widget _walletScreenUnderTest() {
  return MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(authRepository: FakeAuthRepository())),
        BlocProvider(create: (_) => WalletCubit(FakeWalletRepository())),
      ],
      child: const WalletScreen(),
    ),
  );
}

void main() {
  testWidgets('cold start shows the login screen when signed out', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(
            create: (_) => AuthCubit(authRepository: FakeAuthRepository()),
          ),
        ],
        child: const SokoDirectApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets(
    'theme toggle button switches between light and dark once signed in',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      final authCubit = AuthCubit(authRepository: FakeAuthRepository());
      await authCubit.loginWithEmail(
        email: 'farmer@example.com',
        password: 'password123',
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ThemeCubit()),
            BlocProvider.value(value: authCubit),
          ],
          child: const SokoDirectApp(),
        ),
      );
      await tester.pumpAndSettle();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.light);

      await tester.tap(find.byIcon(Icons.brightness_6));
      await tester.pumpAndSettle();

      final updatedApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(updatedApp.themeMode, ThemeMode.dark);
    },
  );

  testWidgets('Wallet screen loads and shows the balance', (tester) async {
    await tester.pumpWidget(_walletScreenUnderTest());

    // Let the async loadWallet() call inside WalletScreen finish.
    await tester.pumpAndSettle();

    expect(find.text('Wallet'), findsOneWidget);
    expect(find.textContaining('RWF'), findsWidgets);
    expect(find.text('Provider: MTN'), findsOneWidget);
  });
}
