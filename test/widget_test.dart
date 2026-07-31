import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:soko_direct/app.dart';
import 'package:soko_direct/core/theme/theme_cubit.dart';
import 'package:soko_direct/features/auth/presentation/cubit/auth_cubit.dart';

import 'helpers/fake_auth_repository.dart';

void main() {
  testWidgets('cold start shows the login screen when signed out', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(
            create: (_) => AuthCubit(authRepository: FakeAuthRepository()),
          ),
        ],
        child: const SokoDirectApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SOKO DIRECT'), findsOneWidget);
    expect(find.text('Connecting Farmers to Buyers'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Flush the splash timer (and the navigation it triggers) so no
    // timers are pending when the test ends.
    await tester.pumpAndSettle(const Duration(milliseconds: 1500));
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets(
    'theme toggle button switches between light and dark once signed in',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      final authCubit = AuthCubit(authRepository: FakeAuthRepository());
      await authCubit.loginWithEmail(
        email: 'farmer@example.com',
        password: 'password123',
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ThemeCubit()),
            BlocProvider.value(value: authCubit),
          ],
          child: const SokoDirectApp(),
        ),
      );
      await tester.pumpAndSettle();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.light);

      await tester.tap(find.byIcon(Icons.brightness_6));
      await tester.pumpAndSettle();

      final updatedApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(updatedApp.themeMode, ThemeMode.dark);
    },
  );
}
