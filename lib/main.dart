import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'core/language/language_cubit.dart';
import 'core/role/role_cubit.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/data/repositories/firebase_auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/dashboard/data/firestore_market_repository.dart';
import 'features/dashboard/presentation/farmer_dashboard_cubit.dart';
import 'features/listings/data/firebase_current_user_repository.dart';
import 'features/listings/data/firestore_listings_repository.dart';
import 'features/listings/domain/current_user_repository.dart';
import 'features/listings/domain/listings_domain.dart';
import 'features/listings/domain/listings_repository.dart';
import 'features/listings/presentation/listings_cubit.dart';
import 'features/offers/data/offer_repository_impl.dart';
import 'features/offers/presentation/farmer_offers_cubit.dart';
import 'features/offers/presentation/offer_cubit.dart';
import 'features/transactions/data/transaction_firestore_repository.dart';
import 'features/transactions/presentation/transaction_cubit.dart';
import 'features/wallet/data/wallet_firestore_repository.dart';
import 'features/wallet/presentation/wallet_cubit.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Avoid a duplicate-app crash on Android, which can auto-init from
  // google-services.json before this call runs.
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  final CurrentUserRepository listingsCurrentUser =
      FirebaseCurrentUserRepository();
  final ListingsRepository listingsRepository = FirestoreListingsRepository();
  final listingsDomain = ListingsDomain(repository: listingsRepository);

  runApp(
    MultiBlocProvider(
      providers: [
        // Core preferences — the 3 persisted settings (theme/language/role).
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => LanguageCubit()),
        BlocProvider(create: (_) => RoleCubit()),

        // Samuel — auth (register/login/Google/logout) + transaction history.
        BlocProvider(
          create: (_) => AuthCubit(authRepository: FirebaseAuthRepository()),
        ),

        // Armstrong — farmer dashboard: LIVE market prices from listings.
        BlocProvider(
          create: (_) => FarmerDashboardCubit(FirestoreMarketRepository()),
        ),

        // Dorcas — offers / negotiation.
        BlocProvider(
          create: (_) => OfferCubit(repository: OfferRepositoryImpl()),
        ),
        BlocProvider(create: (_) => FarmerOffersCubit()),

        // Dorian — wallet + transaction confirmation (real Firestore).
        BlocProvider(create: (_) => WalletCubit(WalletFirestoreRepository())),
        BlocProvider(
          create: (_) =>
              TransactionCubit(TransactionFirestoreRepository()),
        ),

        // Arnold — listings create/edit/delete.
        BlocProvider(
          create: (_) => ListingsCubit(
            domain: listingsDomain,
            authRepository: listingsCurrentUser,
          ),
        ),

        // Teammates: add yours here, e.g.
        // BlocProvider(create: (_) => RatingCubit(repository: RatingRepositoryImpl())),
      ],
      child: const SokoDirectApp(),
    ),
  );
}