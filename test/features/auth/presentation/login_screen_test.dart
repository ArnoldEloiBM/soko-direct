import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soko_direct/core/role/role_cubit.dart';
import 'package:soko_direct/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:soko_direct/features/auth/presentation/cubit/auth_state.dart';
import 'package:soko_direct/features/auth/presentation/screens/login_screen.dart';

import '../../../helpers/fake_auth_repository.dart';

void main() {
  Widget buildSubject() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => RoleCubit()),
          BlocProvider(
            create: (_) => AuthCubit(authRepository: FakeAuthRepository()),
          ),
        ],
        child: const LoginScreen(),
      ),
    );
  }

  testWidgets('shows a validation error when submitting an empty form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pump();

    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
  });

  testWidgets('logs in and reaches the authenticated state on valid input', (
    WidgetTester tester,
  ) async {
    late AuthCubit cubit;

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => RoleCubit()),
            BlocProvider(
              create: (context) {
                cubit = AuthCubit(authRepository: FakeAuthRepository());
                return cubit;
              },
            ),
          ],
          child: const LoginScreen(),
        ),
      ),
    );

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'farmer@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'password123',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Log in'));
    await tester.pumpAndSettle();

    expect(cubit.state.status, AuthStatus.authenticated);
    expect(cubit.state.user?.email, 'farmer@example.com');
  });
}