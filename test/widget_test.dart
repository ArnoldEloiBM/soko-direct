import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soko_direct/app.dart';
import 'package:soko_direct/core/language/language_cubit.dart';
import 'package:soko_direct/core/role/role_cubit.dart';
import 'package:soko_direct/core/theme/theme_cubit.dart';

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
  });
}
