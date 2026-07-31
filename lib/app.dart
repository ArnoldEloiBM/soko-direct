import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/wallet/presentation/wallet_screen.dart';
import 'features/transactions/presentation/transaction_screen.dart';

class SokoDirectApp extends StatelessWidget {
  const SokoDirectApp({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocBuilder rebuilds this widget whenever ThemeCubit emits a new state.
    return BlocBuilder<ThemeCubit, AppThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp(
          title: 'Soko Direct',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode:
              themeMode == AppThemeMode.dark ? ThemeMode.dark : ThemeMode.light,
          home: const TransactionScreen(),
        );
      },
    );
  }
}

/// Temporary screen — replace with real onboarding/role selection once
/// Armstrong's splash + role selection screens are ready.
/// This just proves the Cubit pattern works end to end.
class HomePlaceholder extends StatelessWidget {
  const HomePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Soko Direct')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.brightness_6),
          label: const Text('Toggle Theme'),
          // Screen only calls the Cubit. It never touches SharedPreferences
          // or Firebase directly — that's the whole point of this pattern.
          onPressed: () => context.read<ThemeCubit>().toggleTheme(),
        ),
      ),
    );
  }
}
