import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'core/language/language_cubit.dart';
import 'core/role/role_cubit.dart';
import 'core/theme/theme_cubit.dart';
import 'features/dashboard/data/firestore_market_repository.dart';
import 'features/dashboard/presentation/farmer_dashboard_cubit.dart';
import 'features/offers/data/offer_repository_impl.dart';
import 'features/offers/presentation/offer_cubit.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Guard avoids a duplicate-app crash on Android auto-init.
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(
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

        // Dorcas — offers / negotiation.
        BlocProvider(
          create: (_) => OfferCubit(repository: OfferRepositoryImpl()),
        ),
      ],
      child: const SokoDirectApp(),
    ),
  );
}