import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'core/language/language_cubit.dart';
import 'core/role/role_cubit.dart';
import 'core/theme/theme_cubit.dart';
import 'features/dashboard/data/firestore_market_repository.dart';
import 'features/dashboard/presentation/farmer_dashboard_cubit.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Guard avoids a duplicate-app crash on Android, which can auto-init
  // from google-services.json.
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(
    // Every feature's Cubit gets registered here ONCE, so any screen
    // can reach it with context.read<XCubit>().
    MultiBlocProvider(
      providers: [
        // Core preferences — the 3 persisted settings (theme/language/role).
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => LanguageCubit()),
        BlocProvider(create: (_) => RoleCubit()),

        // Armstrong — farmer dashboard: LIVE market prices from listings.
        BlocProvider(
          create: (_) => FarmerDashboardCubit(FirestoreMarketRepository()),
        ),

        // Teammates: add yours here, e.g.
        // BlocProvider(create: (_) => ListingsCubit(domain: ..., authRepository: ...)),
        // BlocProvider(create: (_) => WalletCubit(FakeWalletRepository())),
      ],
      child: const SokoDirectApp(),
    ),
  );
}
