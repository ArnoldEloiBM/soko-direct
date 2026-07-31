import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/listings/presentation/main_shell.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';

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
          themeMode: themeMode == AppThemeMode.dark
              ? ThemeMode.dark
              : ThemeMode.light,
          home: const MainShell(),
        );
      },
    );
  }
}
