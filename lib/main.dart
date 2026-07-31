import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'app.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/data/repositories/firebase_auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/offers/presentation/offer_cubit.dart';
import 'features/offers/data/offer_repository_impl.dart';
import 'features/wallet/data/fake_wallet_repository.dart';
import 'features/wallet/presentation/wallet_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    // Every feature's Cubit/Bloc gets registered here ONCE, at the top,
    // so any screen in the app can reach it with context.read<XCubit>().
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(
          create: (_) => AuthCubit(authRepository: FirebaseAuthRepository()),
        ),
        BlocProvider(
          create: (_) => OfferCubit(repository: OfferRepositoryImpl()),
        ),
        BlocProvider(create: (_) => WalletCubit(FakeWalletRepository())),

        // Teammates: add yours here, e.g.
        // BlocProvider(create: (_) => ListingsCubit(listingsRepository: ListingsRepository())),
      ],
      child: const SokoDirectApp(),
    ),
  );
}
