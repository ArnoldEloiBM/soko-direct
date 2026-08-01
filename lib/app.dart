import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/onboarding/presentation/splash_screen.dart';

class SokoDirectApp extends StatefulWidget {
  const SokoDirectApp({super.key});

  @override
  State<SokoDirectApp> createState() => _SokoDirectAppState();
}

class _SokoDirectAppState extends State<SokoDirectApp> {
  Key _appKey = UniqueKey();

  @override
  void reassemble() {
    super.reassemble();
    // Hot reload (r) remounts from splash, same as a fresh app open.
    assert(() {
      setState(() => _appKey = UniqueKey());
      return true;
    }());
  }

  @override
  Widget build(BuildContext context) {
    // BlocBuilder rebuilds this widget whenever ThemeCubit emits a new state.
    return BlocBuilder<ThemeCubit, AppThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp(
          key: _appKey,
          title: 'Soko Direct',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
themeMode: themeMode == AppThemeMode.dark
              ? ThemeMode.dark
              : ThemeMode.light,
          home: const SplashScreen(),
        );
      },
    );
  }
}
