import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soko_direct/app.dart';
import 'package:soko_direct/core/language/language_cubit.dart';
import 'package:soko_direct/core/role/role_cubit.dart';
import 'package:soko_direct/core/theme/theme_cubit.dart';
import 'package:soko_direct/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:soko_direct/features/auth/presentation/screens/profile_tab.dart';
import 'package:soko_direct/features/wallet/data/fake_wallet_repository.dart';
import 'package:soko_direct/features/wallet/presentation/wallet_cubit.dart';
import 'package:soko_direct/features/wallet/presentation/wallet_screen.dart';

import 'helpers/fake_auth_repository.dart';

Widget _walletScreenUnderTest() {
  return MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthCubit(authRepository: FakeAuthRepository()),
        ),
        BlocProvider(create: (_) => WalletCubit(FakeWalletRepository())),
      ],
      child: const WalletScreen(),
    ),
  );
}

void main() {
  testWidgets('App cold-starts on the splash screen', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(create: (_) => LanguageCubit()),
          BlocProvider(create: (_) => RoleCubit()),
        ],
        child: const SokoDirectApp(),
      ),
    );

    expect(find.text('SOKO DIRECT'), findsOneWidget);
    expect(find.text('Connecting Farmers to Buyers'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Flush the splash timer (and the navigation it triggers) so no
    // timers are pending when the test ends. With no saved role, this
    // lands on the language/onboarding screen, not login — reaching
    // login/MainShell from cold start is covered by the isolated
    // LoginScreen and ProfileTab tests instead of one giant tree here.
    await tester.pumpAndSettle(const Duration(milliseconds: 1500));
  });

  testWidgets('Wallet screen loads and shows the balance', (tester) async {
    await tester.pumpWidget(_walletScreenUnderTest());

    // Let the async loadWallet() call inside WalletScreen finish.
    await tester.pumpAndSettle();

    expect(find.text('Wallet'), findsOneWidget);
    expect(find.textContaining('RWF'), findsWidgets);
    expect(find.text('Provider: MTN'), findsOneWidget);
  });

  testWidgets('Profile tab shows the signed-in user and toggles theme', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    final themeCubit = ThemeCubit();
    final authCubit = AuthCubit(authRepository: FakeAuthRepository());
    await authCubit.loginWithEmail(
      email: 'farmer@example.com',
      password: 'password123',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: themeCubit),
            BlocProvider.value(value: authCubit),
          ],
          child: const ProfileTab(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Farmer account'), findsOneWidget);

    expect(themeCubit.state, AppThemeMode.light);
    await tester.tap(find.text('Toggle theme'));
    await tester.pump();
    expect(themeCubit.state, AppThemeMode.dark);
  });
}
