import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soko_direct/core/language/language_cubit.dart';
import 'package:soko_direct/core/role/role_cubit.dart';
import 'package:soko_direct/features/onboarding/presentation/language_screen.dart';

void main() {
  testWidgets('language screen shows both options and saves the tapped one',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final languageCubit = LanguageCubit();
    final roleCubit = RoleCubit();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: languageCubit),
          BlocProvider.value(value: roleCubit), // needed by RoleScreen route
        ],
        child: const MaterialApp(home: LanguageScreen()),
      ),
    );

    // Both language buttons are visible (matches the Figma design).
    expect(find.text('Kinyarwanda'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('SOKO DIRECT'), findsOneWidget);

    // Tapping Kinyarwanda saves it through the Cubit -> SharedPreferences.
    await tester.tap(find.text('Kinyarwanda'));
    await tester.pumpAndSettle();

    expect(languageCubit.state, AppLanguage.kinyarwanda);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_language'), 'rw');

    await languageCubit.close();
    await roleCubit.close();
  });
}
