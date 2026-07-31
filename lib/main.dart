import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'core/theme/theme_cubit.dart';
import 'features/auth/data/firebase_auth_repository.dart';
import 'features/auth/domain/auth_repository.dart';
import 'features/listings/data/firestore_listings_repository.dart';
import 'features/listings/domain/listings_domain.dart';
import 'features/listings/domain/listings_repository.dart';
import 'features/listings/presentation/listings_cubit.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  final AuthRepository authRepository = FirebaseAuthRepository();
  final ListingsRepository listingsRepository = FirestoreListingsRepository();
  final listingsDomain = ListingsDomain(repository: listingsRepository);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(
          create: (_) => ListingsCubit(
            domain: listingsDomain,
            authRepository: authRepository,
          ),
        ),
      ],
      child: const SokoDirectApp(),
    ),
  );
}
