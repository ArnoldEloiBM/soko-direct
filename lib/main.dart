import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 
import 'app.dart';
import 'core/theme/theme_cubit.dart';
import 'features/dashboard/data/firestore_market_repository.dart';
import 'features/dashboard/presentation/farmer_dashboard_cubit.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Uncomment once Firebase is set up (see STARTER_GUIDE.md step 6):
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
   );
  runApp(
    // Every feature's Cubit/Bloc gets registered here ONCE, at the top,
    // so any screen in the app can reach it with context.read<XCubit>().
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        // Teammates: add yours here, e.g.
        // BlocProvider(create: (_) => AuthBloc(authRepository: AuthRepository())),
        // BlocProvider(create: (_) => ListingsCubit(listingsRepository: ListingsRepository())),
      ],
      child: const SokoDirectApp(),
    ),
  );
}
